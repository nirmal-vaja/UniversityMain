# frozen_string_literal: true

module Api
  module V1
    # HomeController
    class HomeController < ApiController
      skip_before_action :doorkeeper_authorize!

      def authorization_details
        doorkeeper_client = Doorkeeper::Application.first

        if doorkeeper_client.present?
          success_response(success_options(doorkeeper_client))
        else
          error_response(error_options)
        end
      end

      private

      def success_options(doorkeeper_client)
        {
          data: {
            name: doorkeeper_client.name,
            client_id: doorkeeper_client.uid,
            client_secret: doorkeeper_client.secret
          }
        }
      end

      def error_options
        {
          data: nil,
          message: t('record_not_found')
        }
      end
    end
  end
end
