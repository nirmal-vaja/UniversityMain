class AddressDetail < ApplicationRecord
  include DefaultJsonOptions

  belongs_to :student
end
