class CreateSupportRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :support_requests do |t|
      t.string :subject
      t.text :message
      t.string :status
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
