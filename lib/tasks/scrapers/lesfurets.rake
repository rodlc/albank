namespace :scrapers do
  desc "Scrape LesFurets.com market data for all categories"
  task lesfurets: :environment do
    require 'open-uri'
    require 'nokogiri'

    CATEGORIES = {
      "Assurance Auto" => "https://www.lesfurets.com/assurance-auto",
      "Assurance Habitation" => "https://www.lesfurets.com/assurance-habitation",
      "Électricité & Gaz" => "https://www.lesfurets.com/energie",
      "Banque" => "https://www.lesfurets.com/banque",
      "Assurance Animaux" => "https://www.lesfurets.com/assurance-animaux",
      "Assurance Vélo" => "https://www.lesfurets.com/assurance-velo",
      "Assurance Trottinette" => "https://www.lesfurets.com/assurance-trottinette-electrique",
      "Assurance Smartphone" => "https://www.lesfurets.com/assurance-smartphone",
      "Assurance Emprunteur" => "https://www.lesfurets.com/assurance-emprunteur",
      "Crédit Conso" => "https://www.lesfurets.com/credit-conso",
      "Rachat Crédits" => "https://www.lesfurets.com/rachat-de-credits"
    }

    CATEGORIES.each do |category_name, url|
      puts "Scraping #{category_name}..."

      begin
        html = URI.open(url, "User-Agent" => "Mozilla/5.0")
        doc = Nokogiri::HTML(html)

        # Find category in database
        category = Category.find_by(name: category_name)
        unless category
          puts "  ⚠️  Category '#{category_name}' not found in database, skipping"
          next
        end

        # Look for table with pricing data
        # Selector varies per page - adapt as needed
        prices = []
        doc.css('table tr td').each do |cell|
          text = cell.text.strip
          if text.match?(/\d+[,.]?\d*\s*€/)
            price = text.scan(/\d+[,.]?\d*/).first.gsub(',', '.').to_f
            prices << price if price > 0
          end
        end

        if prices.any?
          average = (prices.sum / prices.size).round(2)
          min_price = prices.min.round(2)
          max_price = prices.max.round(2)

          standard = category.standards.create!(
            average_amount: average,
            min_amount: min_price,
            max_amount: max_price,
            source: "LesFurets",
            source_url: url,
            scraped_at: Time.current,
            unit: "€/mois"
          )

          puts "  ✅ #{category_name}: avg=#{average}€ min=#{min_price}€ max=#{max_price}€"
        else
          puts "  ⚠️  No pricing data found for #{category_name}"
        end

      rescue => e
        puts "  ❌ Error scraping #{category_name}: #{e.message}"
      end

      sleep 1 # Be nice to the server
    end

    puts "\n✨ Scraping complete!"
  end
end
