class ChangeColumnLockedOfStudentMarks < ActiveRecord::Migration[7.0]
  def change
    change_column :student_marks, :locked, :boolean, default: false
    change_column :student_marks, :published, :boolean, default: false
  end
end
