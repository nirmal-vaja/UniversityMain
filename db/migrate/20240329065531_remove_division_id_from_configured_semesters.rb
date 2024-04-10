class RemoveDivisionIdFromConfiguredSemesters < ActiveRecord::Migration[7.0]
  def change
    remove_column :configured_semesters, :division_id, :integer
  end
end
