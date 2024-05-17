class RemoveCourseIdFromStudentBlock < ActiveRecord::Migration[7.0]
  def change
    remove_reference :student_blocks, :course, null: false, foreign_key: true
    remove_reference :student_blocks, :branch, null: false, foreign_key: true
  end
end
