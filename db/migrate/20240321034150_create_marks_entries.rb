class CreateMarksEntries < ActiveRecord::Migration[7.0]
  def change
    create_table :marks_entries do |t|
      t.references :user, null: false, foreign_key: true
      t.string :examination_name
      t.string :academic_year
      t.string :examination_time
      t.string :examination_type
      t.references :course, null: false, foreign_key: true
      t.references :branch, null: false, foreign_key: true
      t.references :semester, null: false, foreign_key: true
      t.references :division, null: false, foreign_key: true

      t.timestamps
    end
  end
end
