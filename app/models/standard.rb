class Standard < ApplicationRecord
  belongs_to :category
  has_many :opportunities

  validates :average_amount, presence: true, numericality: { greater_than: 0 }
end
