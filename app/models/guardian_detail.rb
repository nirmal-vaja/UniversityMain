class GuardianDetail < ApplicationRecord
  include DefaultJsonOptions

  belongs_to :student
end
