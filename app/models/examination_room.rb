# frozen_string_literal: true

# app/models/examination_room.rb
class ExaminationRoom < ApplicationRecord
  belongs_to :course
  belongs_to :branch

  has_many :room_blocks, dependent: :destroy
  has_many :examination_blocks, through: :room_blocks
end
