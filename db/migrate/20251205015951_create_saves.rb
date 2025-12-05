class CreateSaves < ActiveRecord::Migration[7.0]
  def change
    create_table :saves do |t|
      t.references :user, null: false, foreign_key: true
      t.references :saveable, polymorphic: true, null: false

      t.timestamps
    end

    add_index :saves, [:user_id, :saveable_type, :saveable_id], unique: true
  end
end