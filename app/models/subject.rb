# frozen_string_literal: true

# Subject Model
class Subject < ApplicationRecord
  belongs_to :semester
  belongs_to :course
  belongs_to :branch
end
