class CreatePosts < ActiveRecord::Migration[8.0]
  def change
    create_table :posts do |t|
      t.string :title
      t.string :url
      t.text :body
      t.references :user, null: false, foreign_key: true
      t.string :community

      t.timestamps
    end
  end
end
