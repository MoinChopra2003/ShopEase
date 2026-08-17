class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :password_digest
      t.string :status
      t.string :password_reset_token_digest
      t.datetime :password_reset_sent_at

      t.timestamps
    end
  end
end
