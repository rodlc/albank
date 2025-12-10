module ExpensesHelper
  CATEGORY_EMOJIS = {
    /électricité|gaz|énergie/i => "⚡",
    /internet|box|fibre/i => "📡",
    /habitation|logement/i => "🏠",
    /auto|voiture/i => "🚗",
    /moto|scooter/i => "🏍️",
    /mutuelle|santé/i => "🏥",
    /banque|frais/i => "🏦",
    /arnaque|fraude/i => "🏴‍☠️"
  }.freeze

  def category_emoji(category)
    name = category.respond_to?(:name) ? category.name : category.to_s
    CATEGORY_EMOJIS.find { |pattern, _| name.match?(pattern) }&.last || "📋"
  end

  def result_type_config(result_type)
    case result_type&.to_sym
    when :danger
      { emoji: "🚨", label: "Alertes", color: "danger" }
    when :opportunity
      { emoji: "💡", label: "Opportunités", color: "primary" }
    when :success
      { emoji: "⚖️", label: "Optimisé", color: "success" }
    else
      { emoji: "💳", label: "Autres", color: "secondary" }
    end
  end

  def section_totals(expenses)
    total = expenses.sum(&:subtotal)
    savings = expenses.sum { |e| e.opportunities.first&.savings.to_f }
    { total: total, savings: savings }
  end
end
