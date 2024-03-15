# frozen_string_literal: true

# app/models/examination_room.rb
class ExaminationRoom < ApplicationRecord
  belongs_to :course
  belongs_to :branch
end
