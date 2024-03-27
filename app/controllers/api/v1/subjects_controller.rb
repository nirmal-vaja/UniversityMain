# frozen_string_literal: true

module Api
  module V1
    # SubjectsController
    class SubjectsController < ApiController
      before_action :set_subject, only: %w[destroy]

      def index
        @subjects = Subject.where(subject_params)
        success_response(subjects_response)
      end

      def current_course_subjects
        @subjects = current_user.course.subjects
        success_response({ data: { subjects: @subjects } })
      end

      def create
        @subject = Subject.find_or_initialize_by(subject_params.except(:category, :lecture, :tutorial, :practical))
        update_attributes_if_persisted
        handle_response(@subject.persisted? ? true : @subject.save, I18n.t('subjects.created'))
      end

      def destroy
        handle_response(@subject.destroy, I18n.t('subjects.destroy'))
      end

      private

      def set_subject
        @subject = Subject.find_by_id(params[:id])

        error_response({ error: I18n.t('subjects.record_not_found') }) if @subject.nil?
      end

      def update_attributes_if_persisted
        attributes_to_assign = %i[category lecture tutorial practical].each_with_object({}) do |attribute, hash|
          hash[attribute] = subject_params[attribute]
        end

        if @subject.persisted?
          @subject.update_attributes_if_changes(attributes_to_assign)
        else
          @subject.assign_attributes(attributes_to_assign)
        end
      end

      def subject_params
        params.require(:subject).permit(:code, :name, :semester_id, :course_id, :branch_id, :category, :lecture,
                                        :tutorial, :practical)
      end

      def subjects_response
        { data: { subjects: @subjects }, message: I18n.t('subjects.index') }
      end

      def handle_response(success, success_message)
        if success
          success_response({ data: {}, message: success_message })
        else
          error_response({ error: @subject.errors.full_messages.join(', ') })
        end
      end
    end
  end
end
