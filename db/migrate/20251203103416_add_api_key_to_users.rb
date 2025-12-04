class AddApiKeyToUsers < ActiveRecord::Migration[8.0]
  def up
    add_column :users, :api_key, :string
    add_index :users, :api_key, unique: true

    User.reset_column_information
    User.find_each do |user|
      next if user.api_key.present?
      user.update_columns(api_key: SecureRandom.hex(24))
    end
  end

  def down
    remove_index :users, :api_key
    remove_column :users, :api_key
  end
end
