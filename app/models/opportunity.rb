class Opportunity < ApplicationRecord
  belongs_to :statement
  belongs_to :standard

  enum :status, { pending: "pending", contacted: "contacted", completed: "completed" }

  def savings
    statement.amount - standard.average_amount
  end
end
