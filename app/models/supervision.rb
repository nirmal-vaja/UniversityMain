# frozen_string_literal: true

# app/models/supervision.rb
class Supervision < ApplicationRecord
  belongs_to :user
  belongs_to :course
  belongs_to :branch, optional: true
  belongs_to :semester, optional: true

  serialize :metadata, JSON

  def as_json(options = {})
    options[:methods] ||= %i[faculty_name faculty_designation faculty_department]
    super(options)
  end

  def faculty_name
    user.name
  end

  def faculty_designation
    user.designation
  end

  def faculty_department
    user.department
  end
end
