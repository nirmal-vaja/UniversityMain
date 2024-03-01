class CreateSemesters < ActiveRecord::Migration[7.0]
  def change
    create_table :semesters do |t|
      t.references :branch, null: false, foreign_key: true
      t.string :name
      t.integer :number

      t.timestamps
    end
  end
end
