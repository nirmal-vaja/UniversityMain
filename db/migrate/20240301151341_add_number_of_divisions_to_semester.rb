class AddNumberOfDivisionsToSemester < ActiveRecord::Migration[7.0]
  def change
    add_column :semesters, :number_of_divisions, :integer, default: 0
  end
end
