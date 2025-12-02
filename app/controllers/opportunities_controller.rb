class OpportunitiesController < ApplicationController
  before_action :set_opportunity, only: [:show, :update]

  def show
  end

  def update
    if @opportunity.update(opportunity_params)
      redirect_to @opportunity, notice: "Opportunity status updated successfully."
    else
      redirect_to @opportunity, alert: "Failed to update opportunity status."
    end
  end

  private

  def set_opportunity
    @opportunity = Opportunity.find(params[:id])
  end

  def opportunity_params
    params.require(:opportunity).permit(:status)
  end
end
