class ExpensesController < ApplicationController
  before_action :set_statement

  def index
    @expenses = @statement.expenses.includes(:category)
  end

  def show
    @expense = @statement.expenses.find(params[:id])
  end

  private

  def set_statement
    @statement = current_user.statements.find(params[:statement_id])
  end
end
