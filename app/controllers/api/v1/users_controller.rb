# frozen_string_literal: true

module Api
  module V1
    # Users Controller
    class UsersController < ApiController
      skip_before_action :doorkeeper_authorize!, only: %i[create_super_admin check_login_status]
      before_action :set_user, only: %i[update destroy]

      def index
        @users = User.without_role(:super_admin).where(show: true).where(user_params)
        success_response(users_response)
      end

      def create
        @user = User.new(user_params)
        @user.password = 'password'
        @user.show = true
        @user.add_role(:faculty)

        handle_response(@user.save, I18n.t('users.created'))
      end

      def update
        handle_response(@user.update(user_params), I18n.t('users.update'))
      end

      def destroy
        handle_response(@user.destroy, I18n.t('users.destroy'))
      end

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
        return success_response({ data: { super_admin: superadmin_collection.first } }) if superadmin_collection.any?

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

      def set_user
        @user = User.find_by_id(params[:id])

        error_response({ data: {}, error: I18n.t('users.record_not_found') }) if @user.nil?
      end

      def user_params
        return nil unless params['user'].present?

        params.require(:user).permit(:first_name, :last_name, :mobile_number, :email, :gender,
                                     :contact_address, :permanent_address, :course_id, :branch_id,
                                     :user_type, :designation, :date_of_joining).to_h
      end

      def handle_response(success, success_message)
        if success
          success_response({ data: {}, message: success_message })
        else
          error_response({ error: @user.errors.full_messages.join(', ') })
        end
      end

      def users_response
        { data: { users: @users }, message: I18n.t('users.index') }
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
