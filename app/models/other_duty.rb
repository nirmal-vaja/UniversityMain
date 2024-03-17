# frozen_string_literal: true

# app/models/other_duty.rb
class OtherDuty < ApplicationRecord
  belongs_to :user
  belongs_to :course, optional: true
  belongs_to :branch, optional: true

  def as_json(options = {})
    options[:methods] = %i[faculty_name faculty_designation faculty_department]
    super(options)
  end

  def faculty_name
    user.full_name
  end

  def faculty_designation
    user.designation
  end

  def faculty_department
    user.department
  end
end
