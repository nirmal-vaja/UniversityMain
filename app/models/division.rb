# frozen_string_literal: true

# Division Model
class Division < ApplicationRecord
  belongs_to :semester

  def as_json(options = {})
    options[:except] ||= %i[created_at updated_at]

    super(options)
  end
end
