# frozen_string_literal: true

module Api
  module V1
    # common API response module
    module ApiResponders
      extend ActiveSupport::Concern

      private

      def success_response(options)
        response = {
          status_code: options[:status_code] || 200,
          success: options[:success] || true,
          data: options[:data],
          message: options[:message],
          display_message: options[:display_message] || false,
          redirect_flag: options[:redirect_flag] || false
        }
        render json: response
      end

      def error_response(options)
        response = {
          status_code: options[:status_code] || 422,
          success: options[:success] || false,
          data: options[:data] || {},
          message: options[:message] || I18n.t('system_error'),
          error: options[:error],
          display_message: options[:display_message] || false,
          redirect_flag: options[:redirect_flag] || false
        }
        render json: response
      end

      # This method is used to check required params.
      # If any params missing then missing params will came.
      # required params is array and params = request params from caller function.
      def missing_params_response(options)
        # Check required parrams present or not.
        response = {
          status_code: 422,
          success: false,
          data: {},
          message: I18n.t('missing_params'),
          error: I18n.t('missing_params_message'),
          display_message: options[:display_message] || false,
          redirect_flag: options[:redirect_flag] || false
        }

        render status: false, json: response if options[:required_params].all? { |k| options[:params].key? k } == false
      end
    end
  end
end
