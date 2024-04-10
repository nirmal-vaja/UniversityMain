# frozen_string_literal: true

module Api
  module V1
    # app/controllers/api/v1/marks_entries_controller.rb
    class MarksEntriesController < ApiController
      before_action :set_marks_entry, only: %i[update destroy]

      def index
        @marks_entries = MarksEntry.where(sanitized_marks_entry_params)
        success_response({ data: { marks_entries: @marks_entries } })
      end

      def create
        ActiveRecord::Base.transaction do
          @marks_entry = MarksEntry.new(sanitized_marks_entry_params)
          @marks_entry.save!

          @configuration = @marks_entry.user.configs.find_or_initialize_by(config_params)
          @configuration.save!

          @configured_semesters = @configuration.configured_semesters.find_or_initialize_by(configured_semester_params)
          @configured_semesters.subject_ids |= @marks_entry.subjects.pluck(:id)
          @configured_semesters.save!

          @configured_divisions = @configured_semesters.configured_divisions.find_or_initialize_by(configured_division_params)
          @configured_divisions.subject_ids = @marks_entry.subjects.pluck(:id)
          @configured_divisions.save!

          setup_user_role_and_mail

          success_response({ message: I18n.t('marks_entries.create') })
        end
      rescue ActiveRecord::RecordInvalid => e
        error_response({ error: e.message })
      rescue StandardError => e
        error_response({ error: e.message })
      end

      def update
        ActiveRecord::Base.transaction do
          @marks_entry.update!(marks_entry_params_for_update)
          @configuration = @marks_entry.user.configs.find_by(config_params)
          @configured_semesters = @configuration.configured_semesters.find_by(configured_semester_params)
          @configured_divisions = @configured_semesters.configured_divisions.find_by(configured_division_params)

          if @marks_entry.subjects.empty?
            handle_empty_subjects
          else
            update_configured_semesters_and_divisions
          end
          success_response({ message: I18n.t('marks_entries.update') })
        end
      rescue ActiveRecord::RecordInvalid => e
        error_response({ error: e.message })
      rescue StandardError => e
        error_response({ error: e.message })
      end

      def destroy
        if @marks_entry.destroy
          success_response({ message: I18n.t('marks_entries.destroy') })
        else
          error_response({ error: @marks_entry.errors.full_messages.join(', ') })
        end
      end

      private

      def setup_user_role_and_mail
        @marks_entry.user.add_role('Marks Entry') unless @marks_entry.user.has_role?('Marks Entry')
        send_user_mail
      end

      def handle_empty_subjects
        @configured_divisions&.destroy
        return unless @configured_semesters.configured_divisions.empty?

        @configured_semesters.destroy
        @configuration.destroy if @configuration.configured_semesters.empty?
      end

      def update_configured_semesters_and_divisions
        @configured_semesters.subject_ids |= @marks_entry.subjects.pluck(:id)
        @configured_semesters.save!

        @configured_divisions.subject_ids = @marks_entry.subjects.pluck(:id)
        @configured_divisions.save!
      end

      def set_marks_entry
        @marks_entry = MarksEntry.find_by_id(params[:id])
      end

      def send_user_mail
        subject_names = @marks_entry.subjects.pluck(:name)
        UserMailer.send_marks_entry_notification(@marks_entry.user, url: params[:url], role_name: 'Marks Entry',
                                                                    subject_names:).deliver_now
      end

      def marks_entry_params # rubocop:disable Metrics/MethodLength
        params.require(:marks_entry).permit(
          :examination_name,
          :examination_time,
          :examination_type,
          :academic_year,
          :course_id,
          :branch_id,
          :semester_id,
          :division_id,
          :user_id,
          subject_ids: {}
        ).to_h
      end

      def sanitized_marks_entry_params
        return marks_entry_params unless marks_entry_params[:subject_ids].present?

        new_marks_entry_params = marks_entry_params.except(:subject_ids)
        new_marks_entry_params[:subject_ids] = marks_entry_params[:subject_ids].values
        new_marks_entry_params
      end

      def config_params
        marks_entry_params.slice(
          :examination_name,
          :examination_time,
          :examination_type,
          :academic_year,
          :course_id,
          :branch_id,
          :user_id
        )
      end

      def marks_entry_params_for_update
        params.require(:marks_entry).permit(
          :examination_name,
          :examination_time,
          :examination_type,
          :academic_year,
          :course_id,
          :branch_id,
          :semester_id,
          :division_id,
          :user_id,
          subject_ids: []
        ).to_h
      end

      def configured_semester_params
        marks_entry_params.slice(:semester_id)
      end

      def configured_division_params
        marks_entry_params.slice(:division_id)
      end
    end
  end
end
