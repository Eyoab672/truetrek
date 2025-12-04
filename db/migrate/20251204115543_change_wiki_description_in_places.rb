class ChangeWikiDescriptionInPlaces < ActiveRecord::Migration[7.2]
  def change
    change_column :places, :wiki_description, :text
  end
end
