class CreateStudentMarks < ActiveRecord::Migration[7.0]
  def change
    create_table :student_marks do |t|
      t.string :examination_name
      t.string :academic_year
      t.string :examination_time
      t.string :examination_type
      t.references :course, null: false, foreign_key: true
      t.references :branch, null: false, foreign_key: true
      t.references :semester, null: false, foreign_key: true
      t.references :division, null: false, foreign_key: true
      t.references :subject, null: false, foreign_key: true
      t.references :student, null: false, foreign_key: true
      t.string :marks
      t.boolean :locked
      t.boolean :published

      t.timestamps
    end
  end
end
