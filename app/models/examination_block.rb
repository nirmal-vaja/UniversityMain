# frozen_string_literal: true

# app/models/examination_block.rb
class ExaminationBlock < ApplicationRecord
  include DefaultJsonOptions

  belongs_to :course
  belongs_to :branch
  belongs_to :exam_time_table
  belongs_to :subject
  belongs_to :block_extra_config, optional: true

  has_many :student_blocks, dependent: :destroy
  has_many :students, through: :student_blocks

  validate :validate_capacity

  # after_save :update_number_of_students

  scope :having_available_capacity, lambda {
    left_joins(:students)
      .group('examination_blocks.id')
      .having('COUNT(students.id) < examination_blocks.capacity OR COUNT(students.id) IS NULL')
  }

  def as_json(options = {})
    super(options).merge(
      students:,
      remaining_capacity: capacity - students.count
    )
  end

  private

  def update_number_of_students
    update(number_of_students: students.count)
  end

  def validate_capacity
    error.add(:base, 'Number of students exceeds capacity') if number_of_students > capacity
  end
end
