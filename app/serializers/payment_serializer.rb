class PaymentSerializer < ActiveModel::Serializer
  attributes :id, :is_income, :price, :created_at, :updated_at
end
