class Expense < ApplicationRecord
  belongs_to :statement
  belongs_to :category
  has_many :opportunities, dependent: :destroy

  validates :subtotal, presence: true, numericality: { greater_than: 0 }
end
