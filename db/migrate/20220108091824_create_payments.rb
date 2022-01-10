class CreatePayments < ActiveRecord::Migration[6.1]
  def change
    create_table :payments do |t|
      t.boolean :is_income, null: false
      t.integer :price, null: false

      t.timestamps
    end
  end
end
