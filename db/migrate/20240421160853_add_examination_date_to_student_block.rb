class AddExaminationDateToStudentBlock < ActiveRecord::Migration[7.0]
  def change
    add_column :student_blocks, :examination_date, :date
  end
end
