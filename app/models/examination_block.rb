# frozen_string_literal: true

# app/models/examination_block.rb
class ExaminationBlock < ApplicationRecord
  include DefaultJsonOptions

  belongs_to :course
  belongs_to :branch
  belongs_to :exam_time_table
  belongs_to :subject
  belongs_to :block_extra_config, optional: true

  scope :having_available_capacity, lambda {
    joins(:students)
      .group('blocks.id')
      .having('COUNT(students.id) < blocks.capacity')
  }

  def as_json(options = {})
    super(options).merge(
      course:,
      branch:,
      subject:
    )
  end

  private

  def validate_quantity
    error.add(:base, 'Number of students exceeds capacity') if number_of_students > capacity
  end
end
