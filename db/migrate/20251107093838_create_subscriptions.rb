class CreateSubscriptions < ActiveRecord::Migration[7.1]
  def change
    # Si la tabla ya existe, no intentamos crearla de nuevo
    return if table_exists?(:subscriptions)

    create_table :subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :community, null: false, foreign_key: true

      t.timestamps
    end
  end
end
