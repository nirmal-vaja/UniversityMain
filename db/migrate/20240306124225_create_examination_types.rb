class CreateExaminationTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :examination_types do |t|
      t.string :name
      t.integer :maximum_marks
      t.integer :max_students_per_block

      t.timestamps
    end
  end
end
