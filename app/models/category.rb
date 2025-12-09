class Category < ApplicationRecord
  has_many :standards
  has_many :statements

  enum :category_type, { market: "market", blacklist: "blacklist" }

  validates :name, presence: true, uniqueness: true

  scope :blacklist, -> { where(category_type: :blacklist) }
end
