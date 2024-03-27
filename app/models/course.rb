# frozen_string_literal: true

# course model
class Course < ApplicationRecord
  include DefaultJsonOptions

  has_many :branches, dependent: :destroy
  has_many :users, dependent: :destroy

  has_many :exam_time_tables, dependent: :destroy
  has_many :time_table_block_wise_reports, dependent: :destroy
  has_many :examination_blocks, dependent: :destroy

  has_many :subjects, dependent: :destroy

  has_many :block_extra_configs, dependent: :destroy

  def as_json(options = {})
    options[:except] ||= %i[created_at updated_at]

    super(options).merge(
      branches:
    )
  end
end
