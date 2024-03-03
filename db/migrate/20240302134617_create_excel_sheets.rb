class CreateExcelSheets < ActiveRecord::Migration[7.0]
  def change
    create_table :excel_sheets do |t|
      t.string :name

      t.timestamps
    end
  end
end
