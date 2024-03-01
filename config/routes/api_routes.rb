# frozen_string_literal: true

scope :api do
  scope :v1 do
    use_doorkeeper do
      skip_controllers :authorizations, :applications, :authorized_applications
    end
  end
end
