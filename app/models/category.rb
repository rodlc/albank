class Category < ApplicationRecord
  has_many :standards

  validates :name, presence: true, uniqueness: true
end
