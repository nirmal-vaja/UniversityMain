class ApplicationRecord < ActiveRecord::Base
  default_scope { order(created_at: :asc) }
  scope :without_default_scope, -> { unscoped }

  primary_abstract_class
end
