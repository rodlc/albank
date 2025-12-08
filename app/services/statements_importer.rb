class StatementImporter
  def initialize(pdf_file, user)
    @pdf_file = pdf_file
    @user = user # current_user
  end

  def import
    # Parcourir les pages et le texte du PDF
    reader = PDF::Reader.new(@pdf_file.tempfile)

    # créer un RB lié à l'utilisateur, sans le stocker, en ne stockant que la date
    statement = Statement.create!(user: @user, date: Date.today)

    # itère sur chaque page du PDF
    reader.pages.each do |page|
      page.text.each_line do |line|
        # ne prends en compte que les lignes de transaction (avec un format date DD/Mm/YYYY)
        next unless line =~ /\d{2}\/\d{2}\/\d{4}/

        # on va extraire les champs suivants :
        date = line.match(/\d{2}\/\d{2}\/\d{4}/)[0]
        montant = line.match(/-?\d+,\d{2}/)&.to_s
        libelle = line.gsub(date, "").gsub(montant.to_s, "").strip

        # Appel du LLM Processor pour transformer la ligne en Expense
        enriched = LlmProcessor.new(libelle, montant).process
        # retour attendu : { categorie: "Restauration", libelle_enrichi: "Restaurant Le Gourmet" }
        # vérification de l'existence de la catégorie ou création si elle n'existe pas
        category = Category.find_or_create_by(name: enriched[:categorie])

        # Création de la dépense liée au relevé
        Expense.create!(
          statement: statement,
          category: category,
          subtotal: montant.gsub(",", ".").to_f
        )
      end
    end
  end
end
