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

      def create # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
        @marks_entry = MarksEntry.new(sanitized_marks_entry_params)

        begin
          ActiveRecord::Base.transaction do
            raise ActiveRecord::Rollback unless @marks_entry.save

            @configurations = Config.find_or_initialize_by(config_params)
            raise ActiveRecord::Rollback unless @configurations.save

            @configured_semesters = @configurations.configured_semesters.find_or_initialize_by(configured_semester_params) # rubocop:disable Layout/LineLength
            @configured_semesters.subject_ids = @marks_entry.subjects.pluck(:id)
            raise ActiveRecord::Rollback if @configured_semesters.subject_ids.empty? || !@configured_semesters.save

            @marks_entry.user.add_role('Marks Entry') unless @marks_entry.user.has_role?('Marks Entry')
            send_user_mail
            success_response({ message: I18n.t('marks_entries.create') })
          end
        rescue ActiveRecord::Rollback => e
          error_response({ error: "Transaction rolled back: #{e.message}" })
        rescue StandardError => e
          error_response({ error: e.message })
        end
      end

      def update # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
        raise ActiveRecord::Rollback unless @marks_entry.update(sanitized_marks_entry_params)

        send_user_mail

        @configurations = @mark_entry.user.configs&.where(config_params)

        @configurations&.each do |config|
          @configured_semesters = config.configured_semesters.find_by(configured_semester_params)

          @configured_semesters.update(subject_ids: @marks_entry.subjects.pluck(:id)) if @configured_semesters.present?
        end

        success_response({ message: I18n.t('marks_entries.update') })
      rescue ActiveRecord::Rollback => e
        error_response({ error: "Transaction rolled back: #{e.message}" })
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
        return unless marks_entry_params[:subject_ids].present?

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

      def configured_semester_params
        marks_entry_params.slice(:semester_id, :division_id)
      end
    end
  end
end
