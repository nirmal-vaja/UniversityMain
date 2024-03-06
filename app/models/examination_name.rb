# frozen_string_literal: true

# app/models/examination_name.rb
class ExaminationName < ApplicationRecord
  include DefaultJsonOptions
  validates :name, presence: true, uniqueness: true
end
