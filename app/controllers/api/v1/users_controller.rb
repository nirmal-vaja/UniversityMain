# frozen_string_literal: true

module Api
  module V1
    # Users Controller
    class UsersController < ApiController # rubocop:disable Metrics/ClassLength
      skip_before_action :doorkeeper_authorize!, only: %i[create_super_admin check_login_status send_otp]
      before_action :set_user, only: %i[update destroy assign_role revoke_role]
      before_action :set_role_name, only: %i[assign_role revoke_role]

      def index
        @users = User.without_role(:super_admin).where(user_params)
        success_response(users_response)
      end

      def create
        @user = User.new(user_params)
        @user.department = @user.branch.name
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

      def find_user
        user = User.find_by_id(doorkeeper_token[:resource_owner_id])

        if user.present?
          success_response({ data: { user:, roles: user.roles.pluck(:name) }, message: 'User found' })
        else
          error_response({ error: 'User not found.' })
        end
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

      def assigned_role_users # rubocop:disable Metrics/PerceivedComplexity,Metrics/MethodLength,Metrics/CyclomaticComplexity,Metrics/AbcSize
        role_names = Role.all.pluck(:name).reject { |x| ['super_admin', 'faculty', 'Marks Entry'].include?(x) }
        @users = []
        role_names.each do |name|
          if params[:user].present? && user_params[:course_id].present?
            @users << User.where(course_id: user_params[:course_id]).with_any_role(name)
          end
        end
        users = @users&.flatten&.map do |user|
          user.attributes.merge(
            {
              role_names: user.roles_name.reject do |x|
                            ['super_admin', 'faculty', 'Marks Entry'].include?(x)
                          end.join(', ')
            }
          )
        end

        if users
          success_response({ data: { users: }, message: I18n.t('users.index') })
        else
          error_response({ error: 'No users found' })
        end
      end

      def faculty_names # rubocop:disable Metrics/MethodLength
        @users = if params[:request_from] == 'marks_entry'
                   User.without_role('Examination Controller').without_role('Student Coordinator').without_role('Academic Head').without_role('HOD').with_role(:faculty) # rubocop:disable Layout/LineLength
                 else
                   User.with_role(:faculty)
                 end

        @users = @users.where(user_params) if params[:user].present?

        if @users
          success_response({ data: { users: @users } })
        else
          error_response({ error: 'No faculties found' })
        end
      end

      def assign_role
        @user.add_role(@role_name)
        if @user.has_role?(@role_name)
          UserMailer.role_assigned_notification(@user, { role_name: @role_name, url: params[:url] }).deliver_now
          success_response({ data: {}, message: I18n.t('users.role_assigned') })
        else
          error_response({ error: 'Role not assigned' })
        end
      end

      def revoke_role
        @user.remove_role_without_deletion(@role_name)
        unless @user.has_role?(@role_name)
          return success_response({ message: "Successfully revoked Role '#{@role_name}' revoked from #{@user.full_name}." })
        end

        error_response({ data: {},
                         error: "Unable to revoke role '#{@role_name}' from #{user.full_name}. Please try again!" })
      end

      def send_otp
        @user = User.find_by_email(params[:email])
        return error_response({ error: 'User with email you provided not found.' }) unless @user.present?

        @role = @user.find_role_other_than_faculty
        if @role
          generate_and_send_otp
        else
          error_response({ error: 'No roles are assigned to you yet. Contact your admin to assign you some.' })
        end
      end

      private

      def not_logged_in_options
        { message: 'not logged in', data: { logged_in: false } }
      end

      def generate_and_send_otp
        if @user.generate_otp
          @user.send_otp_email
          success_response({ data: { otp: @user.otp }, message: 'OTP has been sent to the entered email.' })
        else
          error_response({ error: 'Something went wrong generating otp, please try again' })
        end
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
                                     :user_type, :designation, :date_of_joining, :password, :role_name).to_h
      end

      def handle_response(success, success_message)
        if success
          success_response({ data: {}, message: success_message })
        else
          error_response({ error: @user.errors.full_messages.join(', ') })
        end
      end

      def set_role_name
        @role_name = user_params[:role_name]
      end

      def users_response
        { data: { users: @users }, message: I18n.t('users.index') }
      end

      def perform_user_specific_tasks(user)
        user.add_role(:super_admin)
        create_default_roles
        token = user.send(:set_reset_password_token)
        UserMailer.send_university_registration_mail(user.email, params[:university], params[:university_url],
                                                     token).deliver_now
      end

      def create_default_roles
        ['Examination Controller', 'Student Coordinator', 'Academic Head', 'HOD', 'Marks Entry'].each do |role|
          Role.find_or_create_by!(name: role)
        end
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
