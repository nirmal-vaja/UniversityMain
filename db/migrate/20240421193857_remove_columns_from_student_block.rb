class RemoveColumnsFromStudentBlock < ActiveRecord::Migration[7.0]
  def change
    remove_column :student_blocks, :examination_name, :string
    remove_column :student_blocks, :examination_time, :string
    remove_column :student_blocks, :academic_year, :string
    remove_column :student_blocks, :examination_type, :string
    remove_column :student_blocks, :examination_date, :date
  end
end
