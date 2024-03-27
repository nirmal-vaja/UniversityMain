class CreateMarksEntrySubjects < ActiveRecord::Migration[7.0]
  def change
    create_table :marks_entry_subjects do |t|
      t.references :marks_entry, null: false, foreign_key: true
      t.references :subject, null: false, foreign_key: true

      t.timestamps
    end
  end
end
