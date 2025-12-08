class CreateReports < ActiveRecord::Migration[7.2]
  def change
    create_table :reports do |t|
      t.references :user, null: false, foreign_key: true
      t.references :place, null: false, foreign_key: true
      t.string :reason, null: false
      t.integer :status, default: 0, null: false

      t.timestamps
    end

    add_index :reports, [:user_id, :place_id], unique: true
  end
end
