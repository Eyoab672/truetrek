class AddImgToCities < ActiveRecord::Migration[7.2]
  def change
    add_column :cities, :img, :string
  end
end
