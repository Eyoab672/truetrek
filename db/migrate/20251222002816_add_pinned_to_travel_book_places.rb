class AddPinnedToTravelBookPlaces < ActiveRecord::Migration[7.2]
  def change
    add_column :travel_book_places, :pinned, :boolean, default: false, null: false
  end
end
