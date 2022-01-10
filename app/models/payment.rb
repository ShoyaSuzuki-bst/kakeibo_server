class Payment < ApplicationRecord
  validates :is_income, presence: true, numericality: [greater_than: 0]
  validates :price, presence: true
end
