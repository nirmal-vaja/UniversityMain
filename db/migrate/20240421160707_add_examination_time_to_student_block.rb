class AddExaminationTimeToStudentBlock < ActiveRecord::Migration[7.0]
  def change
    add_column :student_blocks, :examination_time, :string
    add_column :student_blocks, :examination_type, :string
  end
end
