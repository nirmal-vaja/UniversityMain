class CreateStudentBlocks < ActiveRecord::Migration[7.0]
  def change
    create_table :student_blocks do |t|
      t.references :examination_block, null: false, foreign_key: true
      t.references :student, null: false, foreign_key: true
      t.string :examination_name
      t.string :academic_year
      t.references :course, null: false, foreign_key: true
      t.references :branch, null: false, foreign_key: true

      t.timestamps
    end
  end
end
