# frozen_string_literal: true

module Api
  module V1
    # app/controllers/api/v1/supervisions_controller.rb
    class SupervisionsController < ApiController
      include SupervisionHelpers

      before_action :filtered_supervisions, only: [:index]
      before_action :fetch_block_extra_configs, only: %i[create update]
      before_action :set_supervision, only: %i[update destroy]

      def index
        success_response({ data: { supervisions: @supervisions } })
      end

      def create # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
        @supervision = Supervision.new(supervision_params)
        @supervision.branch = @supervision.user.branch

        # Fetch Available dates to assign.
        @dates = fetch_available_dates(supervision_params, {}, @supervision.user_type)

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

      def update # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
        number_of_supervisions = supervision_params[:number_of_supervisions].to_i

        clear_metadata_if_needed(number_of_supervisions)

        @dates = fetch_available_dates(supervision_params, @supervision.metadata, @supervision.user_type)

        @supervision.metadata = generate_metadata(@supervision, @dates, number_of_supervisions, @block_extra_configs)

        if @supervision.metadata.present?
          if @supervision.update(number_of_supervisions: @supervision.metadata.length)
            success_response({ message: I18n.t('supervisions.updated') })
          else
            error_response({ error: @supervision.errors.full_messages.join(', ') })
          end
        else
          error_response({ error: "You have assigned all the supervisions, can't assign more" })
        end
      end

      def destroy
        if @supervision.destroy
          success_response({ message: I18n.t('supervisions.destroy') })
        else
          error_response({ error: @supervision.errors.full_messages.join(', ') })
        end
      end

      def faculties_without_supervisions
        @faculties = User.left_joins(:supervisions)
                         .with_role(:faculty)
                         .where(supervision_params.slice(:course_id, :branch_id, :user_type))
                         .where.not(id: Supervision.where(supervision_params).pluck(:user_id))

        success_response({ data: { users: @faculties } })
      end

      private

      def clear_metadata_if_needed(number_of_supervisions)
        @supervision.metadata = {} if @supervision.metadata.length >= number_of_supervisions
      end

      def set_supervision
        @supervision = Supervision.find_by_id(params[:id])
        error_response({ error: 'No supervisions found with the supplied id' }) unless @supervision
      end

      def filtered_supervisions
        @supervisions = Supervision.where(supervision_params.except(:examination_date))
        return unless supervision_params[:examination_date].present?

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
        block_extra_config_params = supervision_params.slice(:examination_name, :academic_year, :examination_time,
                                                             :examination_type, :course_id)
        @block_extra_configs = BlockExtraConfig.where(block_extra_config_params).where.not(number_of_supervisions: [
                                                                                             nil, 0
                                                                                           ])
      end
    end
  end
end
