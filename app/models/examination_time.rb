# frozen_string_literal: true

# app/models/examination_time.rb
class ExaminationTime < ApplicationRecord
  include DefaultJsonOptions
  validates :name, presence: true, uniqueness: true
end
