# frozen_string_literal: true

module Api
  module V1
    # BranchesController
    class BranchesController < ApiController
      before_action :set_branch, only: %w[update destroy]

      def index
        @branches = Branch.all
        success_response(branches_response)
      end

      private

      def branches_response
        { data: { branches: @branches }, message: I18n.t('branches.index') }
      end
    end
  end
end
