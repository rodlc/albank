class StatementsController < ApplicationController
  def index
    @statements = current_user.statements.order(date: :desc)
  end

  def show
    @statement = current_user.statements.find(params[:id])
    @expenses = @statement.expenses.includes(:category, :opportunities)
  end

  def new
    @statement = current_user.statements.build
  end

  def create
    @statement = current_user.statements.build(statement_params)

    if @statement.save
      # TODO: Parse PDF and create expenses
      redirect_to @statement, notice: "Statement was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def statement_params
    params.require(:statement).permit(:date)
  end
end
