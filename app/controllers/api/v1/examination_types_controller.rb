# frozen_string_literal: true

module Api
  module V1
    # app/controllers/api/v1/examination_types_controller.rb
    class ExaminationTypesController < ApiController
      before_action :set_examination_type, only: %i[update destroy]

      def index
        @examination_types = ExaminationType.all
        success_response({ data: { examination_types: @examination_types } })
      end

      def create
        @examination_type = ExaminationType.new(examination_type_params)
        return success_response({ message: 'examination_types.create' }) if @examination_type.save

        error_response({ error: @examination_type.errors.full_messages.join(', ') })
      end

      def update
        if @examination_type.update(examination_type_params)
          return success_response({ message: 'examination_types.update' })
        end

        error_response({ error: @examination_type.errors.full_messages.join(', ') })
      end

      def destroy
        return success_response({ message: 'examination_types.destroy' }) if @examination_type.destroy

        error_response({ error: @examintion_name.errors.full_messages.join(', ') })
      end

      private

      def set_examination_type
        @examination_type = ExaminationType.find_by_id(params[:id])
        error_response({ error: 'examination_types.not_found' }) unless @examination_type
      end

      def examination_type_params
        params.require(:examination_type).permit(:name).to_h
      end
    end
  end
end
