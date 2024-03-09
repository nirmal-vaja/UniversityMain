# frozen_string_literal: true

module Api
  module V1
    # BranchesController
    class BranchesController < ApiController
      before_action :set_branch, only: %i[update destroy]

      def index
        @branches = Branch.includes(semesters: :divisions).where(branch_params)
        success_response(branches_response)
      end

      def all_branches
        @branches = Branch.all
        success_response(branches_response)
      end

      def current_user_branches
        return error_response({ error: 'User not logged in' }) unless current_user

        @branches = current_user.branches
        success_response({ data: { branches: @branches, course_id: current_user.course_id } })
      end

      def update
        if @branch.update(branch_params)
          success_response({ data: {}, message: I18n.t('branches.update_record') })
        else
          error_response({ error: @branch.errors.full_messages.join(', ') })
        end
      end

      def destroy
        if @branch.destroy
          success_response({ data: {}, message: I18n.t('branches.destroy_record') })
        else
          error_response({ error: @branch.errors.full_messages.join(', ') })
        end
      end

      private

      def set_branch
        @branch = Branch.find_by_id(params[:id])
      end

      def branch_params
        params.require(:branch).permit(:course_id, :code, :number_of_semesters).to_h
      end

      def branches_response
        { data: { branches: @branches }, message: I18n.t('branches.index') }
      end
    end
  end
end
