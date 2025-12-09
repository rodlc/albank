namespace :scrapers do
  desc "Scrape Signal-Arnaques.com for fraud patterns"
  task signal_arnaques: :environment do
    require 'open-uri'
    require 'nokogiri'

    TAGS = {
      "HPY" => "https://www.signal-arnaques.com/tag/hpy"
    }

    TAGS.each do |tag_name, url|
      puts "Scraping #{tag_name} fraud patterns..."

      begin
        html = URI.open(url, "User-Agent" => "Mozilla/5.0")
        doc = Nokogiri::HTML(html)

        # Extract company names and patterns from articles
        fraud_patterns = []

        doc.css('.article-title, .article-content, h2, h3').each do |element|
          text = element.text.strip.downcase
          # Look for company names or payment patterns
          if text.match?(/pdf|kbis|courrier|helpnumber|bestpdf|proregistre/i)
            fraud_patterns << text
          end
        end

        puts "  Found #{fraud_patterns.size} potential fraud patterns"
        puts "  Sample patterns: #{fraud_patterns.first(5).join(', ')}"

        # Note: This is a basic scraper - actual implementation would need
        # more sophisticated pattern extraction based on Signal-Arnaques HTML structure

      rescue => e
        puts "  ❌ Error scraping #{tag_name}: #{e.message}"
      end
    end

    puts "\n✨ Scraping complete!"
    puts "\nNote: Blacklist categories should be manually reviewed and added to seeds"
    puts "based on verified fraud patterns from Signal-Arnaques.com"
  end
end
