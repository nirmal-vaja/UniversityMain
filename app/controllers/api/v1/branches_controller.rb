# frozen_string_literal: true

module Api
  module V1
    # BranchesController
    class BranchesController < ApiController
      def index
        @branches = Branch.includes(semesters: :divisions).where(branch_params)
        success_response(branches_response)
      end

      private

      def branch_params
        params.require(:branch).permit(:course_id).to_h
      end

      def branches_response
        { data: { branches: @branches }, message: I18n.t('branches.index') }
      end
    end
  end
end
