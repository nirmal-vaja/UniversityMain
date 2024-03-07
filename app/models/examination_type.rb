# frozen_string_literal: true

# app/models/examination_type.rb
class ExaminationType < ApplicationRecord
  include DefaultJsonOptions

  validates :name, presence: true, uniqueness: true
end
