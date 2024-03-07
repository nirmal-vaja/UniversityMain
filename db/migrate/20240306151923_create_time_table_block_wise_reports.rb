class CreateTimeTableBlockWiseReports < ActiveRecord::Migration[7.0]
  def change
    create_table :time_table_block_wise_reports do |t|
      t.string :examination_name
      t.string :academic_year
      t.integer :number_of_students, default: 0
      t.string :examination_type
      t.references :course, null: false, foreign_key: true
      t.references :branch, null: false, foreign_key: true
      t.references :semester, null: false, foreign_key: true
      t.references :exam_time_table, null: false, foreign_key: true
      t.integer :number_of_blocks, default: 0

      t.timestamps
    end
  end
end
