# frozen_string_literal: true

Doorkeeper.configure do
  # Change the ORM that doorkeeper will use (requires ORM extensions installed).
  # Check the list of supported ORMs here: https://github.com/doorkeeper-gem/doorkeeper#orms
  orm :active_record

  resource_owner_from_credentials do
    user = if params[:email].present? && params[:otp].present?
             User.authenticate(params[:email], params[:password], params[:otp])
           else
             User.authenticate(params[:email], params[:password])
           end

    user
  end

  # enable password grant
  grant_flows %w[password]

  allow_blank_redirect_uri true

  skip_authorization do
    true
  end

  use_refresh_token

  access_token_expires_in 10.hours
end
