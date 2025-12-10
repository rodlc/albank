class StatementsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:upload, :process_upload]

  def index
    @statements = current_user.statements.order(date: :desc)
  end

  def show
    @statement = current_user.statements.find(params[:id])
    @expenses = @statement.expenses.includes(:category, :opportunities)
  end

  def upload
    uploaded = params[:file] # ActionDispatch::Http::UploadedFile

    unless uploaded.present?
      redirect_to root_path, alert: "Aucun fichier sélectionné."
      return
    end

    # validations basiques
    if uploaded.size > 10.megabytes
      redirect_to root_path, alert: "Fichier trop volumineux (max 10MB)."
      return
    end

    unless uploaded.content_type.in?(%w(application/pdf application/x-pdf))
      redirect_to root_path, alert: "Format non supporté. Envoyez un PDF."
      return
    end

    if user_signed_in?
      # Créer un fichier persistant (pas Tempfile qui sera supprimé)
      file_path = Rails.root.join("tmp", "upload-#{SecureRandom.uuid}.pdf")
      File.open(file_path, "wb") do |f|
        f.write(uploaded.read)
      end

      # Créer statement en processing
      statement = current_user.statements.create!(date: Date.today, status: :processing)

      # Lancer job background
      ProcessStatementJob.perform_later(statement.id, file_path.to_s)

      redirect_to statement, notice: "Analyse en cours..."
    else
      # stocker temporairement le binaire dans le cache (pas sur disque)
      cache_key = "pending_pdf:#{SecureRandom.uuid}"
      Rails.cache.write(cache_key, { data: uploaded.read, filename: uploaded.original_filename }, expires_in: 15.minutes)
      session[:pending_pdf_key] = cache_key
      redirect_to new_user_session_path, notice: "Connectez-vous pour accéder à vos résultats !"
    end
  end

  def process_upload
    cache_key = session.delete(:pending_pdf_key)

    if cache_key && (cached = Rails.cache.read(cache_key))
      Rails.cache.delete(cache_key)
      # Créer un fichier persistant (pas Tempfile qui sera supprimé)
      file_path = Rails.root.join("tmp", "cached-#{SecureRandom.uuid}.pdf")
      File.open(file_path, "wb") do |f|
        f.write(cached[:data])
      end

      # Créer statement en processing
      statement = current_user.statements.create!(date: Date.today, status: :processing)

      # Lancer job background
      ProcessStatementJob.perform_later(statement.id, file_path.to_s)

      redirect_to statement, notice: "Analyse en cours..."
    else
      redirect_to root_path, alert: "Session expirée ! Réimportez votre relevé."
    end
  end

  private

  # file_path doit être un chemin de fichier string (.pdf)
  def process_pdf_import(file_path, filename = nil)
    # Appel du LLM pour extraire et catégoriser les transactions
    Rails.logger.info("[PDF IMPORT] Processing #{filename || 'uploaded PDF'}")
    data = LlmProcessor.new.process(file_path)
    transactions = data[:transactions] || []

    # Vérifier si le LLM a échoué
    if data[:error]
      Rails.logger.error("[PDF IMPORT] LLM failed: #{data[:error]}")
      redirect_to root_path, alert: "Impossible d'analyser le relevé. Consultez log/llm.log pour les détails."
      return
    end

    # Création du relevé et des dépenses associées
    statement = current_user.statements.create!(date: Date.today, total: data[:total])

    transactions.each do |transaction|
      category = Category.find_by(name: transaction[:category])
      unless category
        Rails.logger.warn("[PDF IMPORT] Catégorie inconnue ignorée: #{transaction[:category]}")
        next
      end

      expense = Expense.create!(
        category: category,
        subtotal: parse_amount(transaction[:amount]),
        label: transaction[:label],
        statement: statement
      )

      # Auto-création des Opportunities si Standard disponible
      standard = Standard.where(category: category)
                         .valid_for_statement(statement.date)
                         .first
      if standard
        opp = Opportunity.create!(expense: expense, standard: standard, status: :pending)
        opp.classify!
      end
    end

    if statement.expenses.count.zero?
      redirect_to statement, alert: "Relevé importé mais aucune dépense récurrente détectée. Vérifiez le format du PDF."
    else
      redirect_to statement, notice: "Relevé importé avec succès ! #{statement.expenses.count} dépenses détectées."
    end
  rescue StandardError => e
    Rails.logger.error("[PDF IMPORT] #{e.class}: #{e.message}")
    Rails.logger.error(e.backtrace.first(10).join("\n"))
    redirect_to root_path, alert: "Erreur lors de l'import du relevé : #{e.message}"
  end

  def parse_amount(value)
    value.to_s.gsub(/[^\d.,\-]/, "").gsub(",", ".").to_f.abs
  end
end
