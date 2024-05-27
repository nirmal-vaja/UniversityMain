class RemoveOccupiedFromExaminationRoom < ActiveRecord::Migration[7.0]
  def change
    remove_column :examination_rooms, :occupied
  end
end
