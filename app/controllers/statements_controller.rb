class StatementsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:upload]

  def index
    @statements = current_user.statements.order(date: :desc)
  end

  def show
    @statement = current_user.statements.find(params[:id])
    @expenses = @statement.expenses.includes(:category, :opportunities)
  end

  def upload
    file = params[:file]

    unless file.present?
      redirect_to root_path, alert: "Aucun fichier sélectionné."
      return
    end

    if user_signed_in?
      process_pdf_import
    else
      store_pending_pdf(file)
      redirect_to new_user_session_path, notice: "Connectez-vous pour accéder à vos résultats !"
    end
  end

  def process_upload
    cache_key = session.delete(:pending_pdf_key)

    if cache_key && Rails.cache.exist?(cache_key)
      Rails.cache.delete(cache_key)
      process_pdf_import
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

  def process_pdf_import
    statement = current_user.statements.create!(date: Date.current.beginning_of_month)
    create_simulated_expenses(statement)

    redirect_to statement, notice: "Relevé importé avec succès ! #{statement.expenses.count} dépenses détectées."
  end

  def create_simulated_expenses(statement)
    # Note: En production, utiliser valid_for_statement(statement.date)
    # Pour la simulation de démo, on utilise sample() pour la variété
    standards_with_categories = Standard.includes(:category).sample(rand(3..4))

    standards_with_categories.each do |standard|
      amount_above_avg = standard.average_amount + rand(10.0..30.0)
      realistic_amount = [amount_above_avg, standard.max_amount + 10].min

      expense = statement.expenses.create!(
        category: standard.category,
        subtotal: realistic_amount.round(2),
        label: "SIMULATION #{standard.category.name.upcase}"
      )

      opportunity = Opportunity.create!(
        expense: expense,
        standard: standard,
        status: "pending"
      )
      opportunity.classify!
    end
  end
end
