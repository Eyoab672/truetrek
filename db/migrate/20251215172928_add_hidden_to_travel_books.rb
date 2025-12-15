class AddHiddenToTravelBooks < ActiveRecord::Migration[7.2]
  def change
    add_column :travel_books, :hidden, :boolean, default: false, null: false
  end
end
