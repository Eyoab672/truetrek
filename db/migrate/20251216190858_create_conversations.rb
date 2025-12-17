class CreateConversations < ActiveRecord::Migration[7.2]
  def change
    create_table :conversations do |t|
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.references :recipient, null: false, foreign_key: { to_table: :users }
      t.boolean :accepted, default: false, null: false
      t.datetime :accepted_at

      t.timestamps
    end

    add_index :conversations, [:sender_id, :recipient_id], unique: true
  end
end
