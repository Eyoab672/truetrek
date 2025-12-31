class AddGroupChatSupport < ActiveRecord::Migration[7.2]
  def change
    # Add group chat fields to conversations
    add_column :conversations, :is_group, :boolean, default: false, null: false
    add_column :conversations, :group_name, :string
    add_reference :conversations, :created_by, foreign_key: { to_table: :users }

    # Make sender/recipient nullable for group chats
    change_column_null :conversations, :sender_id, true
    change_column_null :conversations, :recipient_id, true

    # Create conversation_members join table
    create_table :conversation_members do |t|
      t.references :conversation, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :role, default: 0, null: false # 0 = member, 1 = admin
      t.boolean :muted, default: false, null: false
      t.datetime :joined_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
      t.datetime :left_at

      t.timestamps
    end

    add_index :conversation_members, [:conversation_id, :user_id], unique: true
    add_index :conversation_members, [:user_id, :conversation_id]
  end
end
