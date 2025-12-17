class CreateKeepTabs < ActiveRecord::Migration[7.2]
  def change
    create_table :keep_tabs do |t|
      t.references :follower, null: false, foreign_key: { to_table: :users }
      t.references :followed, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :keep_tabs, [:follower_id, :followed_id], unique: true
  end
end
