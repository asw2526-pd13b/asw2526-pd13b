class CreateCommunities < ActiveRecord::Migration[8.0]
  def change
    create_table :communities do |t|
      t.string :slug
      t.string :name

      t.timestamps
    end
  end
end
