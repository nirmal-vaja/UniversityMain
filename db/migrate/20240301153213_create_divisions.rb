class CreateDivisions < ActiveRecord::Migration[7.0]
  def change
    create_table :divisions do |t|
      t.integer :number
      t.string :name
      t.references :semester, null: false, foreign_key: true

      t.timestamps
    end
  end
end
