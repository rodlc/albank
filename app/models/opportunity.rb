class Opportunity < ApplicationRecord
  belongs_to :expense
  belongs_to :standard

  enum :status, { pending: "pending", contacted: "contacted", completed: "completed" }

  def savings
    expense.subtotal - standard.average_amount
  end
end
