# frozen_string_literal: true

# app/models/TimeTableBlockWiseReport
class TimeTableBlockWiseReport < ApplicationRecord
  include DefaultJsonOptions

  belongs_to :course
  belongs_to :branch
  belongs_to :semester
  belongs_to :exam_time_table

  validates_presence_of :number_of_students
end
