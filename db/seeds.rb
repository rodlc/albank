puts "Cleaning database..."
Opportunity.destroy_all
Expense.destroy_all
Statement.destroy_all
Standard.destroy_all
Category.destroy_all

puts "Creating market categories..."
auto = Category.create!(name: "Assurance Auto", keywords: "auto voiture maif maaf axa allianz direct matmut", category_type: "market")
habitation = Category.create!(name: "Assurance Habitation", keywords: "habitation mrh logement maif maaf axa", category_type: "market")
moto = Category.create!(name: "Assurance Moto", keywords: "moto scooter deux roues", category_type: "market")
mutuelle = Category.create!(name: "Mutuelle Santé", keywords: "mutuelle santé mgen harmonie mgc gsmc", category_type: "market")
energie = Category.create!(name: "Électricité & Gaz", keywords: "edf engie total direct energie enercoop", category_type: "market")
internet = Category.create!(name: "Box Internet", keywords: "orange sfr bouygues free box fibre red bbox", category_type: "market")
banque = Category.create!(name: "Frais Bancaires", keywords: "frais bancaires cotisation carte agios commission interets debiteurs", category_type: "market")
animaux = Category.create!(name: "Assurance Animaux", keywords: "animaux chien chat santé animale", category_type: "market")
velo = Category.create!(name: "Assurance Vélo", keywords: "vélo vae électrique vol casse", category_type: "market")
trottinette = Category.create!(name: "Assurance Trottinette", keywords: "trottinette edpm mobilité électrique", category_type: "market")
smartphone = Category.create!(name: "Assurance Smartphone", keywords: "smartphone mobile téléphone casse vol", category_type: "market")
emprunteur = Category.create!(name: "Assurance Emprunteur", keywords: "emprunteur crédit immobilier prêt", category_type: "market")
credit_conso = Category.create!(name: "Crédit Conso", keywords: "crédit consommation prêt personnel", category_type: "market")
rachat = Category.create!(name: "Rachat Crédits", keywords: "rachat regroupement crédits restructuration", category_type: "market")

puts "Creating blacklist categories..."
arnaque_pdf = Category.create!(name: "Arnaque PDF", keywords: "hpy bestpdf flashpdf pdfzoom documentpdf 123notices pdfcon", category_type: "blacklist")
arnaque_admin = Category.create!(name: "Arnaque Admin", keywords: "hpy kbis proregistre a-verif verifau auto-code pro-ent", category_type: "blacklist")
arnaque_courrier = Category.create!(name: "Arnaque Courrier", keywords: "hpy lettre-m envoi-courrier", category_type: "blacklist")
arnaque_tel = Category.create!(name: "Arnaque Téléphone", keywords: "hpy helpnumber info-perso infonet hipay xp", category_type: "blacklist")
arnaque_abonnement = Category.create!(name: "Arnaque Abonnement", keywords: "cblm straceo medialump reducpriv infopresse", category_type: "blacklist")

puts "Creating standards with scraped data..."
Standard.create!(category: auto, average_amount: 80.5, min_amount: 62.33, unit: "€/mois", source: "LesFurets", source_url: "https://www.lesfurets.com/assurance-auto", scraped_at: Time.current)
Standard.create!(category: habitation, average_amount: 16.33, min_amount: 9.50, unit: "€/mois", source: "LesFurets", source_url: "https://www.lesfurets.com/assurance-habitation", scraped_at: Time.current)
Standard.create!(category: moto, average_amount: 58.7, min_amount: 37.75, max_amount: 69.3, unit: "€/mois", source: "LesFurets", source_url: "https://www.lesfurets.com/assurance-moto", scraped_at: Time.current)
Standard.create!(category: mutuelle, average_amount: 135.0, min_amount: 100.0, max_amount: 180.0, unit: "€/mois", source: "LesFurets", source_url: "https://www.lesfurets.com/mutuelle-sante", scraped_at: Time.current)
Standard.create!(category: internet, average_amount: 25.0, min_amount: 9.99, max_amount: 49.99, unit: "€/mois", source: "LesFurets", source_url: "https://www.lesfurets.com/box-internet", scraped_at: Time.current)
Standard.create!(category: energie, average_amount: 200.0, min_amount: 150.0, max_amount: 250.0, unit: "€/mois", source: "LesFurets", source_url: "https://www.lesfurets.com/energie", scraped_at: Time.current)
Standard.create!(category: banque, average_amount: 17.0, min_amount: 0.0, max_amount: 30.0, unit: "€/mois", source: "LesFurets", source_url: "https://www.lesfurets.com/banque", scraped_at: Time.current)
Standard.create!(category: animaux, average_amount: 40.0, min_amount: 20.0, max_amount: 80.0, unit: "€/mois", source: "LesFurets", source_url: "https://www.lesfurets.com/assurance-animaux", scraped_at: Time.current)
Standard.create!(category: velo, average_amount: 10.0, min_amount: 5.0, max_amount: 20.0, unit: "€/mois", source: "LesFurets", source_url: "https://www.lesfurets.com/assurance-velo", scraped_at: Time.current)
Standard.create!(category: trottinette, average_amount: 15.0, min_amount: 8.0, max_amount: 25.0, unit: "€/mois", source: "LesFurets", source_url: "https://www.lesfurets.com/assurance-trottinette-electrique", scraped_at: Time.current)
Standard.create!(category: smartphone, average_amount: 10.0, min_amount: 5.0, max_amount: 15.0, unit: "€/mois", source: "LesFurets", source_url: "https://www.lesfurets.com/assurance-smartphone", scraped_at: Time.current)
Standard.create!(category: emprunteur, average_amount: 30.0, min_amount: 10.0, max_amount: 80.0, unit: "€/mois", source: "LesFurets", source_url: "https://www.lesfurets.com/assurance-emprunteur", scraped_at: Time.current)
Standard.create!(category: credit_conso, average_amount: 5.0, min_amount: 3.0, max_amount: 8.0, unit: "% TAEG", source: "LesFurets", source_url: "https://www.lesfurets.com/credit-conso", scraped_at: Time.current)
Standard.create!(category: rachat, average_amount: 4.0, min_amount: 2.5, max_amount: 6.0, unit: "% TAEG", source: "LesFurets", source_url: "https://www.lesfurets.com/rachat-de-credits", scraped_at: Time.current)

puts "Creating demo user..."
user = User.find_or_create_by!(email: "demo@albank.bot") do |u|
  u.password = "password"
  u.password_confirmation = "password"
end

puts "Creating statements..."
statement_nov = user.statements.create!(date: Date.new(2025, 11, 1))
statement_dec = user.statements.create!(date: Date.new(2025, 12, 1))

puts "Creating expenses for November statement..."
expense_auto_nov = statement_nov.expenses.create!(category: auto, subtotal: 85.0, label: "DIRECT ASSURANCE AUTO")
expense_internet_nov = statement_nov.expenses.create!(category: internet, subtotal: 45.0, label: "ORANGE INTERNET")
expense_mutuelle_nov = statement_nov.expenses.create!(category: mutuelle, subtotal: 150.0, label: "HARMONIE MUTUELLE")
expense_fraud_pdf = statement_nov.expenses.create!(category: arnaque_pdf, subtotal: 49.90, label: "HPY BESTPDF ABONNEMENT")

puts "Creating expenses for December statement..."
expense_habitation_dec = statement_dec.expenses.create!(category: habitation, subtotal: 12.0, label: "MAAF HABITATION")
expense_internet_dec = statement_dec.expenses.create!(category: internet, subtotal: 42.0, label: "FREE INTERNET")
expense_auto_dec = statement_dec.expenses.create!(category: auto, subtotal: 65.0, label: "AXA AUTO")
expense_fraud_admin = statement_dec.expenses.create!(category: arnaque_admin, subtotal: 39.0, label: "HPY KBIS PROREGISTRE")

puts "Creating opportunities and classifying..."
# Utilise valid_for_statement avec fallback sur le plus récent
standard_auto = Standard.where(category: auto).valid_for_statement(statement_nov.date).first ||
                Standard.where(category: auto).order(scraped_at: :desc).first
standard_internet = Standard.where(category: internet).valid_for_statement(statement_nov.date).first ||
                    Standard.where(category: internet).order(scraped_at: :desc).first
standard_mutuelle = Standard.where(category: mutuelle).valid_for_statement(statement_nov.date).first ||
                    Standard.where(category: mutuelle).order(scraped_at: :desc).first
standard_habitation = Standard.where(category: habitation).valid_for_statement(statement_dec.date).first ||
                      Standard.where(category: habitation).order(scraped_at: :desc).first

opp1 = Opportunity.create!(expense: expense_auto_nov, standard: standard_auto, status: "pending")
opp1.classify!

opp2 = Opportunity.create!(expense: expense_internet_nov, standard: standard_internet, status: "pending")
opp2.classify!

opp3 = Opportunity.create!(expense: expense_mutuelle_nov, standard: standard_mutuelle, status: "contacted")
opp3.classify!

opp4 = Opportunity.create!(expense: expense_fraud_pdf, standard: standard_internet, status: "pending")
opp4.classify!

opp5 = Opportunity.create!(expense: expense_habitation_dec, standard: standard_habitation, status: "completed")
opp5.classify!

opp6 = Opportunity.create!(expense: expense_internet_dec, standard: standard_internet, status: "pending")
opp6.classify!

opp7 = Opportunity.create!(expense: expense_auto_dec, standard: standard_auto, status: "contacted")
opp7.classify!

opp8 = Opportunity.create!(expense: expense_fraud_admin, standard: standard_internet, status: "pending")
opp8.classify!

puts "✓ #{Category.count} categories, #{Standard.count} standards, #{Statement.count} statements, #{Expense.count} expenses, #{Opportunity.count} opportunities created"
