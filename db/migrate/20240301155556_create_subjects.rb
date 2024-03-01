class CreateSubjects < ActiveRecord::Migration[7.0]
  def change
    create_table :subjects do |t|
      t.string :code
      t.string :name
      t.references :semester, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.references :branch, null: false, foreign_key: true
      t.string :category
      t.string :lecture
      t.string :tutorial
      t.string :practical

      t.timestamps
    end
  end
end
