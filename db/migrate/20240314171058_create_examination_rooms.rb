class CreateExaminationRooms < ActiveRecord::Migration[7.0]
  def change
    create_table :examination_rooms do |t|
      t.references :course, null: false, foreign_key: true
      t.references :branch, null: false, foreign_key: true
      t.string :floor
      t.string :room_number
      t.integer :capacity, default: 0
      t.string :building

      t.timestamps
    end
  end
end
