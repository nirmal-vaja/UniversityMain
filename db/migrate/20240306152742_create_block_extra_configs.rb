class CreateBlockExtraConfigs < ActiveRecord::Migration[7.0]
  def change
    create_table :block_extra_configs do |t|
      t.string :examination_name
      t.string :academic_year
      t.references :course, null: false, foreign_key: true
      t.date :examination_date
      t.string :examination_time
      t.integer :number_of_extra_jr_supervisions, default: 0
      t.integer :number_of_extra_sr_supervision, default: 0
      t.string :examination_type
      t.integer :number_of_supervisions, default: 0

      t.timestamps
    end
  end
end
