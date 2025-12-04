class StatementsController < ApplicationController
  def index
    @statements = current_user.statements.order(date: :desc)
  end

  def show
    @statement = current_user.statements.find(params[:id])
    @expenses = @statement.expenses.includes(:category, :opportunities)
  end

  def new
    @statement = current_user.statements.new
  end

  def create
    @statement = current_user.statements.new(statement_params)

    if @statement.save
      # TODO: Parse PDF and create expenses
      redirect_to @statement, notice: "Statement was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def import_pdf
    # Simulate PDF import with realistic demo data
    statement = current_user.statements.create!(date: Date.current.beginning_of_month)
    create_simulated_expenses(statement)

    redirect_to statement, notice: "Relevé importé avec succès ! #{statement.expenses.count} dépenses détectées."
  end

  private

  def statement_params
    params.require(:statement).permit(:date)
  end

  def create_simulated_expenses(statement)
    # Use categories with standards from db:seed
    # Pick 3-4 random categories to simulate variety
    standards_with_categories = Standard.includes(:category).sample(rand(3..4))

    standards_with_categories.each do |standard|
      # Generate amount slightly above average to trigger opportunities
      # Use the standard's min/max range from seed data
      amount_above_avg = standard.average_amount + rand(10.0..30.0)
      realistic_amount = [amount_above_avg, standard.max_amount + 10].min

      expense = statement.expenses.create!(
        category: standard.category,
        subtotal: realistic_amount.round(2)
      )

      # Auto-create opportunity since amount is above average
      Opportunity.create!(
        expense: expense,
        standard: standard,
        status: "pending"
      )
    end
  end
end
