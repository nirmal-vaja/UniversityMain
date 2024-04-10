# frozen_string_literal: true

# Subject Model
class Subject < ApplicationRecord
  belongs_to :semester
  belongs_to :course
  belongs_to :branch

  has_many :exam_time_tables, dependent: :destroy
  has_many :student_marks, dependent: :destroy

  def update_attributes_if_changes(new_attributes)
    assign_attributes(new_attributes)

    changes_to_save = changes.reject { |_, values| values[0] == values[1] }

    return nil if changes_to_save.empty?

    changes.each do |attribute, (old_value, new_value)|
      self[attribute] = new_value if new_value != old_value
    end

    save!
  end
end
