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
      # traiter immédiatement : on passe le binaire en mémoire
      process_pdf_import(StringIO.new(uploaded.read))
    else
      # stocker temporairement le binaire dans le cache (pas sur disque)
      cache_key = "pending_pdf:#{SecureRandom.uuid}"
      Rails.cache.write(cache_key, uploaded.read, expires_in: 15.minutes)
      session[:pending_pdf_key] = cache_key
      redirect_to new_user_session_path, notice: "Connectez-vous pour accéder à vos résultats !"
    end
  end

  def process_upload
    cache_key = session.delete(:pending_pdf_key)

    if cache_key && (data = Rails.cache.exist?(cache_key))
      Rails.cache.delete(cache_key)
      process_pdf_import(StringIO.new(data))
    else
      redirect_to root_path, alert: "Session expirée ! Réimportez votre relevé."
    end
  end

  private

  def store_pending_pdf(file)
    cache_key = "pending_pdf:#{SecureRandom.uuid}"
    Rails.cache.write(cache_key, file.read, expires_in: 15.minutes)
    session[:pending_pdf_key] = cache_key
  end

  # file_io doit être un IO-like (StringIO, Tempfile, ...)
  def process_pdf_import(file_io)
    # audit minimal : hash du binaire (pas le contenu)
    file_io.rewind
    text = PDF::Reader.new(file_io).pages.map(&:text).join("\n")
    # méthode qui masque IBAN, numéros, etc.
    # clean_text = anonymize_text(text)

    # instanciation et injection de dépendance
    data = LlmProcessor.new(text).process
    transactions = data[:transactions] || []



    # appel de l’extraction
    # transactions = llm.extract_expenses_from_text(StringIO.new(text))

    statement = current_user.statements.create(date: Date.today)

    transactions.each do |transaction|
      category = Category.find_by(name: transaction[:category])
      p category ||= Category.find_or_create_by(name: "autres")
      p transaction[:amount]
      Expense.create!(category: category, subtotal: transaction[:amount].abs, statement: statement)
    end

    redirect_to statement, notice: "Relevé importé avec succès ! #{statement.expenses.count} dépenses détectées."
  rescue StandardError => e
    Rails.logger.error("[PDF IMPORT] #{e.class}: #{e.message}")
    redirect_to root_path, alert: "Erreur lors de l'import du relevé."

  end

  def create_simulated_expenses(statement)
    standards_with_categories = Standard.includes(:category).sample(rand(3..4))

    standards_with_categories.each do |standard|
      amount_above_avg = standard.average_amount + rand(10.0..30.0)
      realistic_amount = [amount_above_avg, standard.max_amount + 10].min

      expense = statement.expenses.create!(
        category: standard.category,
        subtotal: realistic_amount.round(2)
      )

      Opportunity.create!(
        expense: expense,
        standard: standard,
        status: "pending"
      )
    end
  end
end
