class AddOriginalDescriptionToPlaces < ActiveRecord::Migration[7.2]
  def change
    add_column :places, :original_description, :text
  end
end
