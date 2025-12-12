class Opportunity < ApplicationRecord
  belongs_to :expense
  belongs_to :standard, optional: true

  enum :status, { pending: "pending", contacted: "contacted", completed: "completed" }
  enum :result_type, { danger: "danger", opportunity: "opportunity", success: "success" }

  def savings
    return 0 unless standard
    expense.subtotal - standard.average_amount
  end

  def classify!
    if danger_detected?
      update!(result_type: :danger)
      return
    end

    # Pas de comparaison si pas de standard (catégories sans benchmark)
    return unless standard

    merchant = expense.merchant_name
    merchant_total = if merchant.blank? || merchant.length < 3
                       expense.subtotal
                     else
                       expense.statement.expenses
                              .where(category: expense.category)
                              .select { |e| e.merchant_name == merchant }
                              .sum(&:subtotal)
                     end

    if merchant_total > standard.average_amount
      update!(result_type: :opportunity)
    else
      update!(result_type: :success)
    end
  end

  private

  def danger_detected?
    normalized_label = normalize_for_matching(expense.label.to_s)

    # Data-driven via Category.keywords
    Category.blacklist.any? do |cat|
      cat.keywords.to_s.split(/[\s,]+/).any? do |pattern|
        normalized_label.include?(normalize_for_matching(pattern))
      end
    end || expense.category.blacklist?
  end

  def normalize_for_matching(text)
    # Supprime espaces, points, tirets, *, _ pour matcher "HPY*BESTPDF" et "H.P.Y."
    text.upcase.gsub(/[\s.\-*_]/, '')
  end
end
