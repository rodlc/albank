class Statement < ApplicationRecord
  belongs_to :user
  has_many :expenses, dependent: :destroy

  validates :date, presence: true
end
