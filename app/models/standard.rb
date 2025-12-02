class Standard < ApplicationRecord
  belongs_to :category

  validates :average_amount, presence: true, numericality: { greater_than: 0 }
end
