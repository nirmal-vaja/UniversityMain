class CreateRoomBlocks < ActiveRecord::Migration[7.0]
  def change
    create_table :room_blocks do |t|
      t.references :examination_room, null: false, foreign_key: true
      t.references :examination_block, null: false, foreign_key: true
      t.string :examination_name
      t.string :examination_type
      t.string :academic_year
      t.references :course, null: false, foreign_key: true
      t.references :branch, null: false, foreign_key: true
      t.string :examination_date
      t.string :examination_time

      t.timestamps
    end
  end
end
