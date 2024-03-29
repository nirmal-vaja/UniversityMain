# frozen_string_literal: true

# branch model
class Branch < ApplicationRecord
  include DefaultJsonOptions

  # associations
  belongs_to :course
  has_many :semesters, dependent: :destroy
  has_many :users, dependent: :destroy

  has_many :exam_time_tables, dependent: :destroy
  has_many :time_table_block_wise_reports, dependent: :destroy
  has_many :examination_blocks, dependent: :destroy

  has_many :subjects, dependent: :destroy

  # Validations
  validates :code, uniqueness: { scope: :course_id }

  # Callbacks
  after_save :update_associated_semesters, if: :saved_change_to_number_of_semesters?

  def as_json(options = {})
    options[:except] ||= %i[created_at updated_at]

    super(options).merge(
      course_name: course.name,
      semesters:,
      subjects:
    )
  end

  private

  def update_associated_semesters
    current_semester_count = semesters.count
    new_semester_count = number_of_semesters

    if new_semester_count > current_semester_count
      create_semesters(new_semester_count - current_semester_count)
    elsif new_semester_count < current_semester_count
      destroy_semesters(current_semester_count - new_semester_count)
    end
  end

  def create_semesters(count)
    starting_number = semesters.exists? ? semesters.maximum(:number) + 1 : 1

    count.times do |i|
      semesters.create(
        number: starting_number + i,
        name: "#{(starting_number + i).ordinalize} Semester"
      )
    end
  end

  def destroy_semesters(count)
    semesters.order(number: :desc).limit(count).destroy_all
  end
end
