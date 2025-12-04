class RenameWikiDescriptionToEnhancedDescription < ActiveRecord::Migration[7.2]
  def change
    rename_column :places, :wiki_description, :enhanced_description
  end
end
