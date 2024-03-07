class AddBlockExtraConfigToExaminationBlock < ActiveRecord::Migration[7.0]
  def change
    add_reference :examination_blocks, :block_extra_config, foreign_key: true
  end
end
