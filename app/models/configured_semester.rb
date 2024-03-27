# frozen_string_literal: true

# app/models/configured_semester.rb5
class ConfiguredSemester < ApplicationRecord
  belongs_to :semester
  belongs_to :division
  belongs_to :config

  serialize :subject_ids, Array
end
