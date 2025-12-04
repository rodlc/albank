class OpportunityMailer < ApplicationMailer
  def negotiation_letter(opportunity, recipient_email)
    @opportunity = opportunity
    @expense = opportunity.expense
    @standard = opportunity.standard
    @savings = opportunity.savings

    mail(
      to: recipient_email,
      subject: "Lettre de renégociation - #{@expense.category.name}"
    )
  end
end
