class AddDefaultUrlToPlaces < ActiveRecord::Migration[7.2]
  def change
    add_column :places, :default_img_url, :string
  end
end
