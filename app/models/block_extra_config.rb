# frozen_string_literal: true

# app/models/block_extra_config.rb
class BlockExtraConfig < ApplicationRecord
  include DefaultJsonOptions

  belongs_to :course
end
