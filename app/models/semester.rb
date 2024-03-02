# frozen_string_literal: true

# semester model
class Semester < ApplicationRecord
  belongs_to :branch
  has_many :divisions, dependent: :destroy

  after_save :update_associated_divisions, if: :saved_change_to_number_of_divisions?

  def as_json(options = {})
    options[:except] ||= %i[created_at updated_at]

    super(options).merge(
      divisions:
    )
  end

  private

  def update_associated_divisions
    current_divisons_count = divisions.count
    new_divisions_count = number_of_divisions

    if new_divisions_count > current_divisons_count
      create_division(new_divisions_count - current_divisons_count)
    elsif new_divisions_count < current_divisons_count
      destroy_division(current_divisons_count - new_divisions_count)
    end
  end

  def create_division(count)
    starting_number = divisions.exists? ? divisions.maximum(:number) + 1 : 1

    count.times do |i|
      divisions.create(
        number: starting_number + i,
        name: "Division #{((starting_number + i) + 64).chr}"
      )
    end
  end

  def destroy_division(count)
    divisions.order(number: :desc).limit(count).destroy_all
  end
end
