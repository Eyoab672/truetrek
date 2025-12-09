class RemoveDescriptionGeneratingFromPlaces < ActiveRecord::Migration[7.2]
  def change
    remove_column :places, :description_generating, :boolean, default: false
    remove_column :places, :description_generation_error, :boolean, default: false
  end
end
