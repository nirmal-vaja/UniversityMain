class AddExaminationTimeToTimeTableBlockWiseReport < ActiveRecord::Migration[7.0]
  def change
    add_column :time_table_block_wise_reports, :examination_time, :string
  end
end
