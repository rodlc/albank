class Statement < ApplicationRecord
  belongs_to :user
  has_many :expenses, dependent: :destroy

  validates :date, presence: true

  # Calculate total amount from danger-type opportunities
  def total_dangers
    expenses.joins(:opportunities)
            .where(opportunities: { result_type: 'danger' })
            .sum(:subtotal)
  end

  # Calculate total potential savings from all opportunities
  def total_savings
    expenses.joins(:opportunities)
            .includes(:opportunities)
            .sum { |e| e.opportunities.sum(&:savings) }
  end

  # Count total number of opportunities
  def total_opportunities
    expenses.joins(:opportunities).count
  end

  # Calculate unrecognized amount (not categorized by LLM)
  def unrecognized_amount
    recognized_total = expenses.sum(:subtotal)
    statement_total = total&.abs || recognized_total
    [statement_total - recognized_total, 0].max
  end
end
