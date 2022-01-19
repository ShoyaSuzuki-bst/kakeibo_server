class AddColumnToPayments < ActiveRecord::Migration[6.1]
  def change
    add_reference :payments, :user, index: true
  end
end
