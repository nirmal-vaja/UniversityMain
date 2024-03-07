class CreateExaminationBlocks < ActiveRecord::Migration[7.0]
  def change
    create_table :examination_blocks do |t|
      t.string :examination_name
      t.string :academic_year
      t.integer :number_of_students, default: 0
      t.string :examination_type
      t.references :course, null: false, foreign_key: true
      t.references :branch, null: false, foreign_key: true
      t.references :exam_time_table, null: false, foreign_key: true
      t.integer :capacity, default: 0
      t.string :name
      t.date :examination_date
      t.string :examination_time
      t.references :subject, null: false, foreign_key: true

      t.timestamps
    end
  end
end
