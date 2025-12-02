puts "Cleaning database..."
Opportunity.destroy_all
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
statement_energie = user.statements.create!(category: energie, amount: 120.0, date: Date.today)
statement_internet = user.statements.create!(category: internet, amount: 45.0, date: Date.today)
statement_auto = user.statements.create!(category: auto, amount: 85.0, date: Date.today)

puts "Creating opportunities..."
standard_energie = Standard.find_by(category: energie)
standard_internet = Standard.find_by(category: internet)
standard_auto = Standard.find_by(category: auto)

Opportunity.create!(statement: statement_energie, standard: standard_energie, status: "pending")
Opportunity.create!(statement: statement_internet, standard: standard_internet, status: "pending")
Opportunity.create!(statement: statement_auto, standard: standard_auto, status: "contacted")

puts "✓ #{Category.count} categories, #{Standard.count} standards, #{Statement.count} statements, #{Opportunity.count} opportunities created"
