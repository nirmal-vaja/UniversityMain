class CreateOtherDuties < ActiveRecord::Migration[7.0]
  def change
    create_table :other_duties do |t|
      t.references :user, null: false, foreign_key: true
      t.references :course, foreign_key: true
      t.references :branch, foreign_key: true
      t.string :examination_name
      t.string :examination_time
      t.string :examination_type
      t.string :academic_year
      t.string :assigned_duties

      t.timestamps
    end
  end
end
