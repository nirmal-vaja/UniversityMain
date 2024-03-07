class CreateExamTimeTables < ActiveRecord::Migration[7.0]
  def todays_wday
    Date.today.wday
  end

  def change
    create_table :exam_time_tables do |t|
      t.string :examination_name
      t.string :examination_time
      t.string :examination_type
      t.references :course, null: false, foreign_key: true
      t.references :branch, null: false, foreign_key: true
      t.references :semester, null: false, foreign_key: true
      t.references :subject, null: false, foreign_key: true
      t.string :academic_year
      t.date :examination_date
      t.integer :day, default: todays_wday

      t.timestamps
    end
  end
end
