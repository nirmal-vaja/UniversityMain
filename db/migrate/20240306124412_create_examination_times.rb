class CreateExaminationTimes < ActiveRecord::Migration[7.0]
  def change
    create_table :examination_times do |t|
      t.string :name

      t.timestamps
    end
  end
end
