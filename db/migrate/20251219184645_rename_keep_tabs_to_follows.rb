class RenameKeepTabsToFollows < ActiveRecord::Migration[7.2]
  def change
    # PostgreSQL automatically renames indexes when table is renamed
    rename_table :keep_tabs, :follows
  end
end
