# frozen_string_literal: true

# app/models/configured_semester.rb5
class ConfiguredSemester < ApplicationRecord
  belongs_to :semester
  belongs_to :config
  has_many :configured_divisions, dependent: :destroy
  has_many :divisions, through: :configured_divisions

  serialize :subject_ids, Array

  def as_json(options = {})
    options[:methods] ||= %i[configured_divisions divisions subjects]
    super(options)
  end

  def subjects
    Subject.where(id: subject_ids)
  end
end
