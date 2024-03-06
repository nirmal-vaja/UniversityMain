# frozen_string_literal: true

module Api
  module V1
    # app/controllers/api/v1/examination_names_controller.rb
    class ExaminationNamesController < ApiController
      before_action :set_examination_name, only: %i[update destroy]

      def index
        @examination_names = ExaminationName.all
        success_response({ data: { examination_names: @examination_names } })
      end

      def create
        @examination_name = ExaminationName.new(examination_name_params)
        success_response({ message: 'examination_names.create' }) if @examination_name.save

        error_response({ error: @examination_name.errors.full_messages.join(', ') })
      end

      def update
        success_response({ message: 'examination_names.update' }) if @examination_name.update(examination_name_params)
        error_response({ error: @examination_name.errors.full_messages.join(', ') })
      end

      def destroy
        success_response({ message: 'examination_names.destroy' }) if @examination_name.destroy
        error_response({ error: @examintion_name.errors.full_messages.join(', ') })
      end

      private

      def set_examination_name
        @examination_name = ExaminationName.find_by_id(params[:id])
        error_response({ error: 'examination_names.not_found' }) unless @examination_name
      end

      def examination_name_params
        params.require(:examination_name).permit(:name).to_h
      end
    end
  end
end
