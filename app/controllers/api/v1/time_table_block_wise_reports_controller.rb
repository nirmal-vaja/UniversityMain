# frozen_string_literal: true

module Api
  module V1
    # app/controllers/api/v1/time_table_block_wise_reports_controller.rb
    class TimeTableBlockWiseReportsController < ApiController
      def index
        @time_table_block_wise_reports = TimeTableBlockWiseReport.where(time_table_block_wise_params)
        success_response({ data: { time_table_block_wise_reports: @time_table_block_wise_reports } })
      end

      private

      def time_table_block_wise_params
        params.require(:time_table_block_wise_report).permit(
          :examination_name,
          :academic_year,
          :examination_time,
          :examination_type,
          :examination_date,
          :course_id,
          :branch_id,
          :semester_id
        )
      end
    end
  end
end
