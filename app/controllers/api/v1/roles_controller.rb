# frozen_string_literal: true

module Api
  module V1
    # api/v1/roles_controller.rb
    class RolesController < ApiController
      def fetch_roles # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
        @course = Course.find_by_id(params[:course_id])
        @remove_role_name = @course.users
                                   .joins(:roles)
                                   .where(roles: { name: 'faculty' })
                                   .where.not(id: User.joins(:roles).group('users.id').having('COUNT(roles.id) = 1').pluck(:id)) # rubocop:disable Layout/LineLength
                                   .flat_map(&:roles)
                                   .map(&:name)
                                   .uniq
        @remove_role_name += ['super_admin', 'faculty', 'Marks Entry']

        @roles = Role.where.not(name: @remove_role_name.uniq)

        if @roles
          success_response({ data: { roles: @roles } })
        else
          error_response({ error: 'No roles found' })
        end
      end
    end
  end
end
