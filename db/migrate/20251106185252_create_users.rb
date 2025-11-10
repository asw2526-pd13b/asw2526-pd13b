class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      ## Camps bàsics
      t.string :email,              null: false, default: ""
      t.string :username,           null: false
      t.string :display_name

      ## OAuth fields
      t.string :provider
      t.string :uid
      t.string :avatar_url

      ## Trackable (opcional però útil)
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      t.timestamps null: false
    end

    add_index :users, :email,                unique: true
    add_index :users, [:provider, :uid],     unique: true
    add_index :users, :username,             unique: true
  end
end