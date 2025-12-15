class AddBannedToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :banned, :boolean, null: false, default: false
    add_column :users, :banned_at, :datetime
    add_column :users, :banned_reason, :string
  end
end
