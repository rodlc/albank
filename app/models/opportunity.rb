class Opportunity < ApplicationRecord
  belongs_to :expense
  belongs_to :standard

  enum :status, { pending: "pending", contacted: "contacted", completed: "completed" }
  enum :result_type, { danger: "danger", opportunity: "opportunity", success: "success" }

  def savings
    expense.subtotal - standard.average_amount
  end

  def classify!
    if danger_detected?
      update!(result_type: :danger)
    elsif expense.subtotal > standard.average_amount
      update!(result_type: :opportunity)
    else
      update!(result_type: :success)
    end
  end

  private

  def danger_detected?
    label = expense.label.to_s.upcase
    # Data-driven via Category.keywords
    Category.blacklist.any? do |cat|
      cat.keywords.to_s.upcase.split(/[\s,]+/).any? { |pattern| label.include?(pattern) }
    end || expense.category.blacklist?
  end
end
