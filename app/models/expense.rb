class Expense < ApplicationRecord
  belongs_to :statement
  belongs_to :category
  has_many :opportunities, dependent: :destroy

  validates :subtotal, presence: true, numericality: { greater_than: 0 }

  def merchant_name
    label.to_s
      .gsub(/\d{2}\/\d{2}/, "")
      .gsub(/\d{10,}/, "")
      .gsub(/Numéro de (client|compte).*$/i, "")
      .strip
      .split(/\s+/).take(3).join(" ").upcase
  end
end
