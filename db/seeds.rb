puts "Cleaning categories..."
Category.destroy_all

puts "Creating categories..."
Category.create!(name: "Assurance Auto", keywords: "auto voiture")
Category.create!(name: "Assurance Habitation", keywords: "habitation logement")
Category.create!(name: "Électricité & Gaz", keywords: "énergie électricité gaz")
Category.create!(name: "Box Internet", keywords: "internet box fibre")
Category.create!(name: "Banque", keywords: "frais bancaires")

puts "✓ #{Category.count} categories created"
