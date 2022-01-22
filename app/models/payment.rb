class Payment < ApplicationRecord
  validates :is_income, inclusion: {in: [true, false]}
  validates :price, presence: true, numericality: [greater_than: 0]
end
