# frozen_string_literal: true

module Api
  module V1
    # app/controllers/api/v1/other_duties_controller.rb
    class OtherDutiesController < ApiController
      before_action :filtered_other_duties, only: [:index]
      before_action :set_other_duty, only: %i[update destroy]

      def index
        success_response({ data: { other_duties: @other_duties } })
      end

      def create
        @other_duty = OtherDuty.new(other_duty_params)
        @other_duty.branch = @other_duty.user.branch

        if @other_duty.save
          success_response({ message: I18n.t('other_duties.created') })
        else
          error_response({ error: @other_duty.errors.full_messages.join(', ') })
        end
      end

      def update
        if @other_duty.update(other_duty_params)
          success_response({ message: I18n.t('other_duties.updated') })
        else
          error_response({ error: @other_duty.errors.full_messages.join(', ') })
        end
      end

      def fetch_unsupervised_faculties
        @faculties = User.left_joins(:supervisions)
                         .with_role(:faculty)
                         .where(other_duty_params.slice(:course_id, :branch_id))
                         .where(supervisions: { id: nil })
        success_response({ data: { users: @faculties } })
      end

      def destroy
        if @other_duty.destroy
          success_response({ message: I18n.t('other_duties.destroy') })
        else
          error_response({ error: @other_duty.errors.full_messages.join(', ') })
        end
      end

      private

      def set_other_duty
        @other_duty = OtherDuty.find_by_id(params[:id])
        error_response({ error: 'No record found.' }) unless @other_duty
      end

      def other_duty_params
        params.require(:other_duty).permit(:examination_name, :examination_time, :examination_type, :academic_year,
                                           :course_id, :branch_id, :user_id, :assigned_duties).to_h
      end

      def filtered_other_duties
        @other_duties = OtherDuty.where(other_duty_params.except(:assigned_duties))
      end
    end
  end
end
