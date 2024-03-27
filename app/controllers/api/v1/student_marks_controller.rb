# frozen_string_literal: true

module Api
  module V1
    # app/controllers/api/v1/student_marks_controller.rb
    class StudentMarksController < ApiController
      before_action :set_student_mark, only: %i[update destroy]

      def index
        @student_marks = StudentMark.where(student_marks_params)
        success_response({ data: { student_marks: @student_marks } })
      end

      def create
        @student_mark = StudentMark.new(student_marks_params)
        if @student_mark.save
          success_response({ message: 'Operation successfull.' })
        else
          error_response({ error: @student_mark.errors.full_messages.join(', ') })
        end
      end

      def update
        if @student_mark.update(student_marks_params)
          success_response({ message: 'Operation successfull.' })
        else
          error_response({ error: @student_mark.errors.full_messages.join(', ') })
        end
      end

      def destroy
        if @student.destroy
          success_response({ message: 'Operation successfull.' })
        else
          error_response({ error: @student_mark.errors.full_messages.join(', ') })
        end
      end

      private

      def set_student_mark
        @student_mark = StudentMark.find_by_id(params[:id])
        success_response({ message: 'No student marks found for the selected filter' }) unless @student_mark
      end

      def student_marks_params # rubocop:disable Metrics/MethodLength
        params.require(:student_mark).permit(
          :examination_name,
          :academic_year,
          :examination_time,
          :examination_type,
          :course_id,
          :branch_id,
          :semester_id,
          :branch_id,
          :division_id,
          :subject_id,
          :student_id,
          :marks
        )
      end
    end
  end
end
