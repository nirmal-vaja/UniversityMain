class CreateSupervisions < ActiveRecord::Migration[7.0]
  def change
    create_table :supervisions do |t|
      t.text :metadata
      t.references :user, null: false, foreign_key: true
      t.string :examination_name
      t.string :academic_year
      t.string :examination_type
      t.string :examination_time
      t.references :course, null: false, foreign_key: true
      t.string :user_type
      t.integer :number_of_supervisions, default: 0
      t.references :branch, foreign_key: true
      t.references :semester, foreign_key: true

      t.timestamps
    end
  end
end
