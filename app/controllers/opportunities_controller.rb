class OpportunitiesController < ApplicationController
  before_action :set_statement_and_expense
  before_action :set_opportunity, only: [:show, :update]

  def show
  end

  def update
    if @opportunity.update(opportunity_params)
      redirect_to statement_expense_opportunity_path(@statement, @expense, @opportunity),
                  notice: "Opportunity status updated successfully."
    else
      redirect_to statement_expense_opportunity_path(@statement, @expense, @opportunity),
                  alert: "Failed to update opportunity status."
    end
  end

  private

  def set_statement_and_expense
    @statement = current_user.statements.find(params[:statement_id])
    @expense = @statement.expenses.find(params[:expense_id])
  end

  def set_opportunity
    @opportunity = @expense.opportunities.find(params[:id])
  end

  def opportunity_params
    params.require(:opportunity).permit(:status)
  end
end
