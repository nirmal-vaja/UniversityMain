# frozen_string_literal: true

# Contact Detail Model
class ContactDetail < ApplicationRecord
  belongs_to :student

  validates :personal_email_address, presence: true
  validates :mobile_number, presence: true

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
