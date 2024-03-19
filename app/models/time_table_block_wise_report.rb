# frozen_string_literal: true

# app/models/TimeTableBlockWiseReport
class TimeTableBlockWiseReport < ApplicationRecord
  include DefaultJsonOptions

  belongs_to :course
  belongs_to :branch
  belongs_to :semester
  belongs_to :exam_time_table

  validates_presence_of :number_of_students

  def as_json(options = {})
    options[:methods] ||= %i[subject_name subject_code]
    super(options)
  end

  def subject_name
    exam_time_table.subject_name
  end

  def subject_code
    exam_time_table.subject_code
  end
end
