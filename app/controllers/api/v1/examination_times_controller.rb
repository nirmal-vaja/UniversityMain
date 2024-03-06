# frozen_string_literal: true

module Api
  module V1
    # app/controllers/api/v1/examination_times_controller.rb
    class ExaminationTimesController < ApiController
      before_action :set_examination_time, only: %i[update destroy]

      def index
        @examination_times = ExaminationTime.all
        success_response({ data: { examination_times: @examination_times } })
      end

      def create
        @examination_time = ExaminationTime.new(examination_time_params)
        success_response({ message: 'examination_times.create' }) if @examination_time.save

        error_response({ error: @examination_time.errors.full_messages.join(', ') })
      end

      def update
        success_response({ message: 'examination_times.update' }) if @examination_time.update(examination_time_params)
        error_response({ error: @examination_time.errors.full_messages.join(', ') })
      end

      def destroy
        success_response({ message: 'examination_times.destroy' }) if @examination_time.destroy
        error_response({ error: @examintion_name.errors.full_messages.join(', ') })
      end

      private

      def set_examination_time
        @examination_time = ExaminationTime.find_by_id(params[:id])
        error_response({ error: 'examination_times.not_found' }) unless @examination_time
      end

      def examination_time_params
        params.require(:examination_time).permit(:name).to_h
      end
    end
  end
end
