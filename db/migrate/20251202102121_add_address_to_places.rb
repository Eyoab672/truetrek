class AddAddressToPlaces < ActiveRecord::Migration[7.2]
  def change
    add_column :places, :address, :string
  end
end
