# frozen_string_literal: true

# Api Controller
class ApiController < ApplicationController
  # equivalent of authenticate_user! on devise, but this one will check the oauth token.
  # before_action :authenticate_user!
  # include Pagy::Backend
  include Pundit::Authorization
  include Api::V1::ApiResponders
  before_action :doorkeeper_authorize!
  rescue_from Pundit::NotAuthorizedError do |exception|
    policy = exception.policy
    policy_name = exception.policy.class.to_s.underscore

    error_key = if policy.respond_to?(:policy_error_key) && policy.policy_error_key
                  policy.policy_error_message
                else
                  exception.query
                end

    error_response({ message: I18n.t("#{policy_name}.#{error_key}", scope: 'pundit', default: :default) })
  end
  # Skip checking CSRF token authenticity for API requests.

  # set responce type
  respond_to :json

  private

  # helper method to access the current user from the token
  def current_user
    @current_user ||= User.find_by(id: doorkeeper_token[:resource_owner_id])
  end
end
