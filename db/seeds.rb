puts "Cleaning database..."
Standard.destroy_all
puts "Cleaning categories..."
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

puts "✓ #{Category.count} categories, #{Standard.count} standards created"