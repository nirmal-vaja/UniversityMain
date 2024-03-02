# frozen_string_literal: true

# course model
class Course < ApplicationRecord
  has_many :branches, dependent: :destroy
  has_many :users, dependent: :destroy

  def as_json(options = {})
    super(options).merge(
      branches:
    )
  end
end
