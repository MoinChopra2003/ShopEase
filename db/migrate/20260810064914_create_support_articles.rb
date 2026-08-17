class CreateSupportArticles < ActiveRecord::Migration[8.1]
  def change
    create_table :support_articles do |t|
      t.string :title
      t.text :content
      t.integer :position
      t.boolean :active

      t.timestamps
    end
  end
end
