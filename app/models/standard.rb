class Standard < ApplicationRecord
  belongs_to :category
  has_many :opportunities

  validates :average_amount, presence: true, numericality: { greater_than: 0 }

  FRESHNESS_THRESHOLD = 3.months

  # Scope pour standards valides pour une date de relevé donnée
  scope :valid_for_statement, ->(statement_date) {
    where('scraped_at >= ?', statement_date - FRESHNESS_THRESHOLD)
      .order(scraped_at: :desc)
  }

  # Vérifie si le standard est périmé pour une date donnée
  def stale_for?(statement_date)
    return false if scraped_at.nil?
    scraped_at < statement_date - FRESHNESS_THRESHOLD
  end

  # Retourne l'état de fraîcheur du standard
  def freshness_for(statement_date)
    return :unknown if scraped_at.nil?

    days_old = (statement_date.to_date - scraped_at.to_date).to_i
    case days_old
    when ..30 then :fresh      # < 1 mois
    when 31..90 then :recent   # 1-3 mois
    else :stale                # > 3 mois
    end
  end
end
