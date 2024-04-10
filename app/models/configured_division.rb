# frozen_string_literal: true

# apps/models/configured_divisions.rb
class ConfiguredDivision < ApplicationRecord
  belongs_to :configured_semester
  belongs_to :division

  serialize :subject_ids, Array

  def as_json(options = {})
    options[:methods] ||= [:subjects]
    super(options)
  end

  def subjects
    Subject.where(id: subject_ids)
  end
end
