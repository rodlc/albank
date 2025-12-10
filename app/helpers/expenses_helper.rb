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
      { emoji: "💳", label: "Dépenses non récurrentes", color: "secondary" }
    end
  end

  def section_totals(expenses)
    total = expenses.sum(&:subtotal)
    savings = expenses.sum { |e| e.opportunities.first&.savings.to_f }
    { total: total, savings: savings }
  end

  def group_expenses(expenses)
    # Groupe les dépenses par catégorie + bénéficiaire similaire
    expenses.group_by do |expense|
      [
        expense.category_id,
        extract_merchant_name(expense.label)
      ]
    end.map do |key, grouped_expenses|
      if grouped_expenses.size > 1
        # Fusionner les dépenses
        merged_expense = grouped_expenses.first.dup
        merged_expense.subtotal = grouped_expenses.sum(&:subtotal)
        merged_expense.define_singleton_method(:grouped_expenses) { grouped_expenses }
        merged_expense.define_singleton_method(:grouped?) { true }
        merged_expense
      else
        # Dépense unique
        expense = grouped_expenses.first
        expense.define_singleton_method(:grouped?) { false }
        expense
      end
    end
  end

  def extract_merchant_name(label)
    # Extrait le nom du bénéficiaire (EDF, MAIF, etc.)
    # Ignore les dates, numéros de compte, etc.
    cleaned = label
      .gsub(/\d{2}\/\d{2}/, "") # Dates 23/07
      .gsub(/\d{10,}/, "")      # Numéros longs
      .gsub(/Numéro de (client|compte).*$/i, "") # Infos client
      .strip

    # Garde les 3 premiers mots significatifs
    cleaned.split(/\s+/).take(3).join(" ").upcase
  end
end
