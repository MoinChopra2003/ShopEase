class CreateAddresses < ActiveRecord::Migration[8.1]
  def change
    create_table :addresses do |t|
      t.string :label
      t.string :recipient_name
      t.string :phone_number
      t.string :address
      t.string :city
      t.string :postal_code
      t.string :country
      t.decimal :latitude
      t.decimal :longitude
      t.boolean :default
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
