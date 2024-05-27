class AddOccupiedToRoomBlock < ActiveRecord::Migration[7.0]
  def change
    add_column :room_blocks, :occupied, :integer, default: 0
  end
end
