class Statement < ApplicationRecord
  belongs_to :user
  belongs_to :category
  has_many :opportunities, dependent: :destroy

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :date, presence: true
end
