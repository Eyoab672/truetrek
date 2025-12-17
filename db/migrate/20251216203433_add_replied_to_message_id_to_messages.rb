class AddRepliedToMessageIdToMessages < ActiveRecord::Migration[7.2]
  def change
    add_reference :messages, :replied_to_message, foreign_key: { to_table: :messages }
  end
end
