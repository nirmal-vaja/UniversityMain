# frozen_string_literal: true

# app/models/exam_time_table.rb
class ExamTimeTable < ApplicationRecord
  include DefaultJsonOptions

  # callbacks
  after_commit :destroy_block_extra_configs, on: %i[destroy update]

  # belongs_to associations
  belongs_to :course
  belongs_to :branch
  belongs_to :semester
  belongs_to :subject

  # has_one , many and through associations
  has_one :time_table_block_wise_report, dependent: :destroy
  has_many :examination_blocks, dependent: :destroy

  # validations
  validates_presence_of :examination_name, :examination_time, :examination_date, :examination_type
  validates :subject_id, uniqueness: { scope: %i[examination_name academic_year] }

  # enums
  enum day: {
    Sunday: 0,
    Monday: 1,
    Tuesday: 2,
    Wednesday: 3,
    Thursday: 4,
    Friday: 5,
    Saturday: 6
  }

  def as_json(options = {})
    options[:methods] ||= %i[subject_name subject_code]
    super(options)
  end

  def subject_name
    subject&.name
  end

  def subject_code
    subject&.code
  end

  private

  def destroy_block_extra_configs # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
    conditions = { examination_date:, examination_time:, examination_name:, examination_type:, academic_year:,
                   course_id: }

    exam_time_tables = ExamTimeTable.where(conditions)

    block_extra_configs = BlockExtraConfig.where(conditions)
    if exam_time_tables.present?
      block_extra_configs.tap do |configs|
        if configs.exists?
          configs.update_all(number_of_supervisions: exam_time_tables.sum do |x|
                                                       x.time_table_block_wise_report&.number_of_blocks.to_i
                                                     end)
        end
      end
    else
      block_extra_configs.destroy_all
    end
  end
end
