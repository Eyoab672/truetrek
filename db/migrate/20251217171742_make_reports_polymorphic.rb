class MakeReportsPolymorphic < ActiveRecord::Migration[7.2]
  def up
    # Add polymorphic columns
    add_column :reports, :reportable_type, :string
    add_column :reports, :reportable_id, :bigint

    # Migrate existing data: place_id -> reportable
    Report.reset_column_information
    Report.where.not(place_id: nil).update_all("reportable_type = 'Place', reportable_id = place_id")

    # Remove old uniqueness index
    remove_index :reports, [:user_id, :place_id]

    # Remove the old foreign key and column
    remove_foreign_key :reports, :places
    remove_column :reports, :place_id

    # Make polymorphic columns required
    change_column_null :reports, :reportable_type, false
    change_column_null :reports, :reportable_id, false

    # Add new polymorphic index for efficient queries
    add_index :reports, [:reportable_type, :reportable_id]

    # Add uniqueness constraint: one user can only report each item once
    add_index :reports, [:user_id, :reportable_type, :reportable_id], unique: true, name: 'index_reports_on_user_and_reportable'
  end

  def down
    # Add back place_id column
    add_reference :reports, :place, foreign_key: true

    # Migrate data back
    Report.reset_column_information
    Report.where(reportable_type: 'Place').update_all("place_id = reportable_id")

    # Remove polymorphic index
    remove_index :reports, [:reportable_type, :reportable_id]
    remove_index :reports, name: 'index_reports_on_user_and_reportable'

    # Remove polymorphic columns
    remove_column :reports, :reportable_type
    remove_column :reports, :reportable_id

    # Re-add old uniqueness index
    add_index :reports, [:user_id, :place_id], unique: true
  end
end
