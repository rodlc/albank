class Category < ApplicationRecord
  has_many :standards
  has_many :statements

  validates :name, presence: true, uniqueness: true
end
