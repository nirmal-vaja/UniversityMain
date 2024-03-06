# frozen_string_literal: true

# app/models/examination_time.rb
class ExaminationTime < ApplicationRecord
  validates :name, presence: true, uniqueness: true
end
