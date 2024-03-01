# frozen_string_literal: true

module Api
  module V1
    # Users Controller
    class UsersController < ApiController
      skip_before_action :doorkeeper_authorize!, only: %i[create_super_admin check_login_status]

      def check_login_status
        return error_response(not_logged_in_options) unless doorkeeper_token

        if doorkeeper_token.expired? || doorkeeper_token.revoked_at.present?
          error_response(not_logged_in_options)
        else
          success_response(logged_in_options)
        end
      end

      def create_super_admin
        superadmin_collection = User.with_role(:super_admin)
        return superadmin_collection if superadmin_collection.any?

        user = User.new(user_params)

        if user.save
          perform_user_specific_tasks(user)
          success_response(success_options)
        else
          error_response(error_options(user))
        end
      end

      private

      def not_logged_in_options
        { message: 'not logged in', data: { logged_in: false } }
      end

      def logged_in_options
        { message: 'logged in', data: { logged_in: true } }
      end

      def user_params
        params.require(:user).permit(:first_name, :last_name, :mobile_number, :email, :password, :gender,
                                     :contact_address, :permanent_address).to_h
      end

      def perform_user_specific_tasks(user)
        user.add_role(:super_admin)
        token = user.send(:set_reset_password_token)
        UserMailer.send_university_registration_mail(user.email, params[:university], params[:university_url],
                                                     token).deliver_now
      end

      def success_options
        {
          data: {},
          message: I18n.t('users.super_admin_created'),
          display_message: true
        }
      end

      def error_options(user)
        {
          data: {},
          message: user.errors.full_messages.join(', '),
          display_message: true
        }
      end
    end
  end
end
