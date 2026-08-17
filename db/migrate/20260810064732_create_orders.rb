class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.string :order_number
      t.string :status
      t.decimal :subtotal
      t.decimal :total_price
      t.references :user, null: false, foreign_key: true
      t.references :address, null: true, foreign_key: true
      t.jsonb :delivery_address_snapshot

      t.timestamps
    end
    add_index :orders, :order_number, unique: true
  end
end
