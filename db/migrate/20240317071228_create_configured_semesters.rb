class CreateConfiguredSemesters < ActiveRecord::Migration[7.0]
  def change
    create_table :configured_semesters do |t|
      t.references :semester, null: false, foreign_key: true
      t.references :division, null: false, foreign_key: true
      t.text :subject_ids
      t.references :config, null: false, foreign_key: true

      t.timestamps
    end
  end
end
