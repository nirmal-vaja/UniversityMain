# frozen_string_literal: true

module Api
  module V1
    # app/controllers/api/v1/block_extra_configs_controller.rb
    class BlockExtraConfigsController < ApiController
      before_action :set_block_extra_config, only: %i[show update]

      def index
        @block_extra_configs = current_user.course.block_extra_configs.where(block_extra_config_params)
        success_response({ data: { block_extra_configs: @block_extra_configs } })
      end

      def show
        success_response({ data: { block_extra_config: @block_extra_config } })
      end

      def update
        if @block_extra_config.update(block_extra_config_params)
          success_response({ message: I18n.t('block_extra_configs.update') })
        else
          error_response({ error: @block_extra_config.errors.full_messages.join(', ') })
        end
      end

      private

      def set_block_extra_config
        @block_extra_config = current_user.course.block_extra_configs.find_by_id(params[:id])
        error_response({ error: I18n.t('block_extra_configs.not_found') }) unless @block_extra_config
      end

      def block_extra_config_params
        params.require(:block_extra_config).permit(
          :examination_name,
          :academic_year,
          :examination_date,
          :examination_time,
          :number_of_extra_jr_supervisions,
          :number_of_extra_sr_supervision,
          :examination_type,
          :number_of_supervisions
        ).to_h
      end
    end
  end
end
