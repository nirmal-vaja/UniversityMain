class CreateConfiguredDivisions < ActiveRecord::Migration[7.0]
  def change
    create_table :configured_divisions do |t|
      t.references :configured_semester, null: false, foreign_key: true
      t.references :division, null: false, foreign_key: true
      t.text :subject_ids

      t.timestamps
    end
  end
end
