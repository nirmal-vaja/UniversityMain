class RoomBlock < ApplicationRecord
  belongs_to :examination_room
  belongs_to :examination_block
  belongs_to :course
  belongs_to :branch
end
