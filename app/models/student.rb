# frozen_string_literal: true

# Student Model
class Student < ApplicationRecord
  belongs_to :course
  belongs_to :branch
  belongs_to :semester
  belongs_to :division

  scope :fees_paid, -> { where(fees_paid: true) }
  scope :fees_unpaid, -> { where(fees_paid: false) }

  validates :name, presence: true

  has_one :contact_detail, dependent: :destroy
  has_one :address_detail, dependent: :destroy
  has_one :parent_detail, dependent: :destroy
  has_one :guardian_detail, dependent: :destroy

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
