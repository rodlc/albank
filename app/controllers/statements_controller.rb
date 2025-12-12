class StatementsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:upload, :process_upload]

  def index
    @statements = current_user.statements.order(date: :desc)
  end

  def show
    @statement = current_user.statements.find(params[:id])
    @expenses = @statement.expenses.includes(:category, :opportunities)
  end

  def destroy
    @statement = current_user.statements.find(params[:id])
    @statement.destroy
    redirect_to statements_path, notice: "Relevé supprimé"
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
      # traiter immédiatement : on passe le binaire en mémoire
      process_pdf_import(StringIO.new(uploaded.read), uploaded.original_filename)
    else
      # stocker temporairement le binaire dans le cache (pas sur disque)
      cache_key = "pending_pdf:#{SecureRandom.uuid}"
      Rails.cache.write(cache_key, uploaded.read, expires_in: 15.minutes)
      session[:pending_pdf_key] = cache_key
      session[:pending_pdf_filename] = uploaded.original_filename
      redirect_to new_user_session_path, notice: "Connectez-vous pour accéder à vos résultats !"
    end
  end

  def process_upload
    cache_key = session.delete(:pending_pdf_key)

    if cache_key && (data = Rails.cache.read(cache_key))
      Rails.cache.delete(cache_key)
      process_pdf_import(StringIO.new(data), session.delete(:pending_pdf_filename))
    else
      redirect_to root_path, alert: "Session expirée ! Réimportez votre relevé."
    end
  end

  private

  # file_io doit être un IO-like (StringIO, Tempfile, ...)
  def process_pdf_import(file_io, filename = nil)
    # Mode demo si fichier demo.pdf
    if filename&.downcase == "demo.pdf"
      sleep(20)  # Simulate LLM processing
      data = demo_statement_data
      transactions = data[:transactions] || []
    else
      # Extraction du texte brut du PDF
      file_io.rewind
      text = PDF::Reader.new(file_io).pages.map(&:text).join("\n")

      # Appel du LLM pour extraire et catégoriser les transactions
      data = LlmProcessor.new(text).process
      transactions = data[:transactions] || []
    end

    # Création du relevé et des dépenses associées
    statement_date = Date.parse(data[:statement_date]) rescue Date.today
    statement = current_user.statements.create(date: statement_date, total: data[:total])

    transactions.each do |transaction|
      category = Category.find_by(name: transaction[:category])
      unless category
        Rails.logger.warn("[PDF IMPORT] Catégorie inconnue ignorée: #{transaction[:category]}")
        next
      end

      expense = Expense.create!(
        category: category,
        subtotal: transaction[:amount].to_f.abs,
        label: transaction[:label],
        statement: statement
      )

      # Auto-création des Opportunities
      standard = Standard.where(category: category).order(scraped_at: :desc).first

      # Pour les blacklist : toujours créer une Opportunity (même sans Standard)
      # Pour les market : seulement si Standard existe
      if category.blacklist? || standard
        opp = Opportunity.create!(expense: expense, standard: standard, status: :pending)
        opp.classify!
      end
    end

    redirect_to statement, notice: "Relevé importé avec succès ! #{statement.expenses.count} dépenses détectées."
  rescue StandardError => e
    Rails.logger.error("[PDF IMPORT] #{e.class}: #{e.message}")
    redirect_to root_path, alert: "Erreur lors de l'import du relevé."
  end

  def demo_statement_data
    {
      statement_date: Date.current.beginning_of_month.to_s,
      total: 1657.92,
      transactions: [
        { label: "PRLV SEPA Alan Insurance ALAN SANTE 278573", category: "Mutuelle Santé", amount: 121.00 },
        { label: "PRLV SEPA LOLIVER ASSURANCE E.U ADMIRAL Policy 847291", category: "Assurance Auto", amount: 59.53 },
        { label: "PRLV SEPA AVANTSSUR Direct Assurance 200016091216", category: "Assurance Auto", amount: 10.44 },
        { label: "PRLV SEPA EDF clients particuliers Numero de client 6030489124", category: "Électricité & Gaz", amount: 215.00 },
        { label: "PRLV SEPA EAU DU GRAND LYON LA REGIE EGL 2124124", category: "Électricité & Gaz", amount: 14.55 },
        { label: "CARTE 01/12 Starlink Europe", category: "Box Internet", amount: 29.00 },
        { label: "HPY*BESTPDF ABONNEMENT 49.90", category: "Arnaque PDF", amount: 49.90 },
        { label: "FRAIS TENUE DE COMPTE DECEMBRE", category: "Frais Bancaires", amount: 8.50 }
      ]
    }
  end
end
