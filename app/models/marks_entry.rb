# frozen_string_literal: true

# app/models/marks_entry.rb
class MarksEntry < ApplicationRecord
  belongs_to :user
  belongs_to :course
  belongs_to :branch
  belongs_to :semester
  belongs_to :division

  has_many :marks_entry_subjects, dependent: :destroy
  has_many :subjects, through: :marks_entry_subjects

  after_update :sanitize_data, if: :no_marks_entry_subjects_found

  def as_json(options = {})
    options[:methods] = %i[faculty_name faculty_designation faculty_department subjects division subject_ids]
    super(options)
  end

  def faculty_name
    user.full_name
  end

  def subject_ids
    subjects.pluck(:id)
  end

  def faculty_designation
    user.designation
  end

  def faculty_department
    user.branch_name
  end

  private

  def no_marks_entry_subjects_found
    marks_entry_subjects.count.zero?
  end

  def sanitize_data
    destroy
  end
end
