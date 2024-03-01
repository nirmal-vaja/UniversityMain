class CreateBranches < ActiveRecord::Migration[7.0]
  def change
    create_table :branches do |t|
      t.references :course, null: false, foreign_key: true
      t.string :name
      t.string :code
      t.integer :number_of_semesters, default: 0

      t.timestamps
    end
  end
end
