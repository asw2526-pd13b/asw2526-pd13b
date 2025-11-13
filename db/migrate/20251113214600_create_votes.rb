class CreateVotes < ActiveRecord::Migration[8.0]
  def change
    create_table :votes do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :value
      t.references :votable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
