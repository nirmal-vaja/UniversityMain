# frozen_string_literal: true

module Api
  module V1
    # app/controllers/api/v1/supervisions_controller.rb
    class SupervisionsController < ApiController
      include SupervisionHelpers

      before_action :filtered_supervisions, only: [:index]
      before_action :fetch_block_extra_configs, only: [:create]

      def index
        success_response({ data: { supervisions: @supervisions } })
      end

      def create
        @supervision = Supervision.new(supervision_params)
        @supervision.branch = @supervision.user.branch

        # Fetch Available dates to assign.
        @dates = fetch_available_dates(supervision_params, {})
        @supervision.metadata = generate_metadata(@supervision, @dates, @supervision.number_of_supervisions,
                                                  @block_extra_configs)

        if @supervision.metadata.present?
          if @supervision.save
            success_response({ message: I18n.t('supervisions.created') })
          else
            error_response({ error: @supervisons.errors.full_message.join(', ') })
          end
        else
          error_response({ error: I18n.t('supervisions.no_exam_dates_found') })
        end
      end

      private

      def filtered_supervisions
        @supervisions = Supervision.where(supervision_params.except(:date))
        return unless supervision_params[:date].present?

        date = "%#{supervision_params[:date]}%"
        @supervisions = @supervisions.where('metadata LIKE ?', date)
      end

      def supervision_params # rubocop:disable Metrics/MethodLength
        params.require(:supervision).permit(
          :examination_name,
          :academic_year,
          :examination_type,
          :examination_time,
          :course_id,
          :branch_id,
          :user_id,
          :number_of_supervisions,
          :user_type
        ).to_h
      end

      def fetch_block_extra_configs
        @block_extra_configs = BlockExtraConfig.where(supervision_params).where.not(number_of_supervisions: [nil, 0])
      end
    end
  end
end
