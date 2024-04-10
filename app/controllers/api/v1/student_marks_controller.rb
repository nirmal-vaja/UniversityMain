# frozen_string_literal: true

module Api
  module V1
    # app/controllers/api/v1/student_marks_controller.rb
    class StudentMarksController < ApiController # rubocop:disable Metrics/ClassLength
      before_action :set_student_mark, only: %i[update destroy]
      before_action :find_student_marks_from_subject_id, only: %i[lock_marks unlock_marks]

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

      def retrieve_unique_subjects_for_lock_marks
        @subjects = Subject.joins(:student_marks).where(student_marks: student_marks_params).distinct
        @subjects = @subjects.map do |subject|
          student_marks = StudentMark.where(student_marks_params).where(subject_id: subject.id)
          subject.attributes.merge({
                                     locked: student_marks.pluck(:locked).include?(true)
                                   })
        end
        success_response({ data: { subjects: @subjects } })
      end

      def retrieve_unique_subjects_for_unlock_marks
        @subjects = Subject.joins(:student_marks).where(student_marks: student_marks_params.merge(locked: true)).distinct
        @actual_subjects = Subject.where(student_marks_params.slice(:course_id, :branch_id, :semester_id))
        subjects_ids = @subjects.map(&:id)
        @publish_status = StudentMark.where(subject_id: subjects_ids).first&.published
        success_response({ data: { subjects: @subjects,
                                   eligible_for_publish_marks: @actual_subjects.length == @subjects.length,
                                   published: @publish_status } })
      end

      def lock_marks
        if @student_marks.update_all(locked: true)
          success_response({ message: 'Marks has been locked' })
        else
          error_response({ error: 'Error locking marks, please try again' })
        end
      end

      def unlock_marks
        if @student_marks.update_all(locked: false)
          success_response({ message: 'Marks has been unlocked' })
        else
          error_response({ error: 'Error unlocking marks, please try again' })
        end
      end

      def publish_marks
        @student_marks = StudentMark.where(student_marks_params)
        if @student_marks.update_all(published: true)
          success_response({ message: 'Marks has been published' })
        else
          error_response({ error: "Can't publish marks, please try again!" })
        end
      end

      def unpublish_marks
        @student_marks = StudentMark.where(student_marks_params)

        if @student_marks.update_all(published: false)
          success_response({ message: 'Marks has been unpublished' })
        else
          error_response({ error: "Can't unpublish marks, please try again!" })
        end
      end

      def marksheet_data
        @students = Student.where(sanitized_marksheet_params.slice(:course_id, :branch_id, :semester_id, :division_id))

        @student_marks = StudentMark.where(sanitized_marksheet_params).where(published: true)
        @examination_types = ExaminationType.all
        response = []
        @students&.each do |student|
          student_marks = @student_marks.where(student_id: student.id)
          response_hash = {}
          response_hash[:student_enrollment_number] =  student.enrollment_number.to_i.to_s
          response_hash[:student_name] = student.name
          response_hash[:student_semester_name] = student.semester_name
          response_hash[:marksheet_data] = student_marks
          @examination_types.each do |type|
            response_hash[type.name] = student_marks.where(examination_type: type.name)
                                                    .joins(:subject)
                                                    .pluck('subjects.name', :marks)
                                                    .to_h
          end
          response << response_hash
        end

        success_response({ data: { marksheet_data: response } })
      end

      private

      def find_student_marks_from_subject_id
        @student_marks = StudentMark.where(student_marks_params).where(subject_id: params[:id])
        return @student_marks if @student_marks

        error_response({ error: 'No studentmarks found for the selected filter, so you cant perform any actions.' })
      end

      def set_student_mark
        @student_mark = StudentMark.find_by_id(params[:id])
        success_response({ message: 'No student marks found for the selected filter' }) unless @student_mark
      end

      def marksheet_params
        params.require(:student_mark).permit(
          :examination_name,
          :examination_time,
          :academic_year,
          :course_id,
          :branch_id,
          :semester_id,
          :division_id,
          examination_types: {}
        ).to_h
      end

      def sanitized_marksheet_params
        new_marksheet_params = marksheet_params.except(:examination_types)

        new_marksheet_params[:examination_type] = marksheet_params[:examination_types].values
        new_marksheet_params
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
          :marks,
          :locked
        ).to_h
      end
    end
  end
end
