# frozen_string_literal: true

# app/models/student_mark.rb
class StudentMark < ApplicationRecord
  belongs_to :course
  belongs_to :branch
  belongs_to :semester
  belongs_to :division
  belongs_to :subject
  belongs_to :student

  validate :marks_within_maximum_marks

  def as_json(options = {})
    options[:methods] ||= %i[student_name student_enrollment_number]
    super(options)
  end

  def marks_within_maximum_marks
    type = ExaminationType.find_by_name(examination_type)

    return unless marks.present? && (marks != 'Ab' && marks != 'ZR') && marks.to_i > type.maximum_marks

    errors.add(:marks, "cannot exceed maximum marks for #{examination_type}")
  end

  def student_name
    student.name
  end

  def student_enrollment_number
    student.enrollment_number
  end
end
