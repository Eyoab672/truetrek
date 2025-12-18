class AddTourCompletedToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :tour_completed, :boolean, default: false, null: false
  end
end
