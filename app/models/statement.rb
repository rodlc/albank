class Statement < ApplicationRecord
  belongs_to :user
  has_many :expenses, dependent: :destroy

  enum :status, { processing: 0, ready: 1, failed: 2 }

  validates :date, presence: true
end
