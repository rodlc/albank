puts "Cleaning database..."
Opportunity.destroy_all
Expense.destroy_all
Statement.destroy_all
Standard.destroy_all
Category.destroy_all

puts "Creating categories..."
auto = Category.create!(name: "Assurance Auto", keywords: "auto voiture")
habitation = Category.create!(name: "Assurance Habitation", keywords: "habitation logement")
energie = Category.create!(name: "Électricité & Gaz", keywords: "énergie électricité gaz")
internet = Category.create!(name: "Box Internet", keywords: "internet box fibre")
banque = Category.create!(name: "Banque", keywords: "frais bancaires")

puts "Creating standards..."
Standard.create!(category: energie, average_amount: 80.0, min_amount: 60.0, max_amount: 120.0, unit: "€/mois", date: Date.today, tiering: "standard")
Standard.create!(category: internet, average_amount: 30.0, min_amount: 20.0, max_amount: 50.0, unit: "€/mois", date: Date.today, tiering: "standard")
Standard.create!(category: auto, average_amount: 50.0, min_amount: 35.0, max_amount: 80.0, unit: "€/mois", date: Date.today, tiering: "standard")
Standard.create!(category: habitation, average_amount: 25.0, min_amount: 15.0, max_amount: 40.0, unit: "€/mois", date: Date.today, tiering: "standard")
Standard.create!(category: banque, average_amount: 5.0, min_amount: 0.0, max_amount: 10.0, unit: "€/mois", date: Date.today, tiering: "standard")

puts "Creating demo user..."
user = User.find_or_create_by!(email: "demo@albank.bot") do |u|
  u.password = "password"
  u.password_confirmation = "password"
end

puts "Creating statements..."
statement_nov = user.statements.create!(date: Date.new(2025, 11, 1))
statement_dec = user.statements.create!(date: Date.new(2025, 12, 1))

puts "Creating expenses for November statement..."
expense_energie_nov = statement_nov.expenses.create!(category: energie, subtotal: 120.0)
expense_internet_nov = statement_nov.expenses.create!(category: internet, subtotal: 45.0)
expense_auto_nov = statement_nov.expenses.create!(category: auto, subtotal: 85.0)

puts "Creating expenses for December statement..."
expense_energie_dec = statement_dec.expenses.create!(category: energie, subtotal: 110.0)
expense_internet_dec = statement_dec.expenses.create!(category: internet, subtotal: 42.0)
expense_habitation_dec = statement_dec.expenses.create!(category: habitation, subtotal: 35.0)

puts "Creating opportunities..."
standard_energie = Standard.find_by(category: energie)
standard_internet = Standard.find_by(category: internet)
standard_auto = Standard.find_by(category: auto)
standard_habitation = Standard.find_by(category: habitation)

Opportunity.create!(expense: expense_energie_nov, standard: standard_energie, status: "pending")
Opportunity.create!(expense: expense_internet_nov, standard: standard_internet, status: "pending")
Opportunity.create!(expense: expense_auto_nov, standard: standard_auto, status: "contacted")
Opportunity.create!(expense: expense_energie_dec, standard: standard_energie, status: "pending")
Opportunity.create!(expense: expense_habitation_dec, standard: standard_habitation, status: "completed")

puts "✓ #{Category.count} categories, #{Standard.count} standards, #{Statement.count} statements, #{Expense.count} expenses, #{Opportunity.count} opportunities created"
