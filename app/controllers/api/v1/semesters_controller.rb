# frozen_string_literal: true

module Api
  module V1
    # SemestersController
    class SemestersController < ApiController
      before_action :set_semester, only: %w[update destroy]

      def index
        @semesters = Semester.includes(:divisions).where(semester_params)
        success_response(semesters_response)
      end

      def update
        handle_response(@semester.update(semester_params), I18n.t('semesters.update'))
      end

      def destroy
        handle_response(@semester.destroy, I18n.t('semesters.destroy'))
      end

      private

      def set_semester
        @semester = Semester.find_by_id(params[:id])

        error_response({ error: I18n.t('semesters.record_not_found') }) if @semester.nil?
      end

      def semester_params
        params.require(:semester).permit(:name, :number_of_divisions, :branch_id)
      end

      def semesters_response
        { data: { semesters: @semesters }, message: I18n.t('semesters.index') }
      end

      def handle_response(success, success_message)
        if success
          success_response({ data: {}, message: success_message })
        else
          error_response({ error: @semester.errors.full_messages.join(', ') })
        end
      end
    end
  end
end
