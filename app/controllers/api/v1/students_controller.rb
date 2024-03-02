# frozen_string_literal: true

module Api
  module V1
    # Students Controller
    class StudentsController < ApiController
      before_action :set_student, only: %i[update destroy]

      def index
        @students = Student.where(student_params)
        success_response(students_response)
      end

      def create
        @student = Student.find_or_initialize_by(enrollment_number: student_params[:enrollment_number])
        res = update_attributes
        if res.is_a?(String)
          error_response({ error: res, display_message: true })
        else
          handle_response(@student.persisted? && res.nil? ? true : @student.save, I18n.t('students.created'))
        end
      end

      def destroy
        handle_response(@student.destroy, I18n.t('students.destroy'))
      end

      private

      def set_student
        @student = Student.find_by_id(params[:id])

        error_response({ data: {}, error: I18n.t('students.record_not_found') }) if @student.nil?
      end

      def student_params
        params.require(:student).permit(:name, :enrollment_number, :course_id, :branch_id, :semester_id, :division_id,
                                        :father_name, :mother_name, :date_of_birth, :birth_place, :religion,
                                        :caste, :blood_group, :gender).to_h
      end

      def update_attributes
        if @student.persisted?
          @student.update_attributes_if_changes(student_params)
          @student.contact_detail.update_attributes_if_changes(student_contact_details_params)
        else
          @student.assign_attributes(student_params)
          @contact_detail = @student.build_contact_detail(student_contact_details_params)
          @contact_detail.errors.full_messages.join(', ') unless @contact_detail.valid?
        end
      end

      def student_contact_details_params
        params.require(:contact_detail).permit(:mobile_number, :personal_email_address, :university_email_address).to_h
      end

      def handle_response(success, success_message)
        if success
          success_response({ data: {}, message: success_message })
        else
          error_response({ error: @student.errors.full_messages.join(', ') })
        end
      end

      def students_response
        { data: { students: @students }, message: I18n.t('students.index') }
      end
    end
  end
end
