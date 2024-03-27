class Config < ApplicationRecord
  belongs_to :course
  belongs_to :branch
  belongs_to :user

  has_many :configured_semesters, dependent: :destroy
  has_many :semesters, through: :configured_semesters
  has_many :divisions, through: :configured_semesters

  def as_json(options = {})
    options[:methods] ||= %i[configured_semesters semesters divisions]
    super(options)
  end
end
