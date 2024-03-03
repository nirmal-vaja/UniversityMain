# frozen_string_literal: true

# ExcelSheet model
class ExcelSheet < ApplicationRecord
  has_one_attached :sheet, dependent: :destroy

  validates_presence_of :sheet, :name
  validates_uniqueness_of :name
end
