# frozen_string_literal: true

# Student Model
class Student < ApplicationRecord
  belongs_to :course
  belongs_to :branch
  belongs_to :semester
  belongs_to :division

  scope :fees_paid, -> { where(fees_paid: true) }
  scope :fees_unpaid, -> { where(fees_paid: false) }

  has_one :contact_detail, dependent: :destroy
  has_one :address_detail, dependent: :destroy
  has_one :parent_detail, dependent: :destroy
  has_one :guardian_detail, dependent: :destroy
end
