class AddOccupiedToExaminationRoom < ActiveRecord::Migration[7.0]
  def change
    add_column :examination_rooms, :occupied, :integer, default: 0
  end
end
