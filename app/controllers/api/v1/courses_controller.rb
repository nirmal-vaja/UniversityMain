# frozen_string_literal: true

module Api
  module V1
    # CoursesController
    class CoursesController < ApiController
      before_action :set_course, only: %w[update destroy]

      def index
        @courses = Course.includes(branches: { semesters: :divisions })
        success_response({ data: { courses: @courses }, message: I18n.t('courses.index') })
      end

      def create
        @course = Course.find_or_initialize_by(course_params)
        res = create_branch_and_semesters
        if @course.new_record? && @course.errors.any?
          error_response({ error: @course.errors.full_messages.join(', ') })
        elsif res.is_a?(String)
          error_response({ error: res, display_message: true })
        else
          success_response({ message: I18n.t('courses.created'), display_message: true })
        end
      end

      def destroy
        res = destroy_branch
        if res.is_a?(String)
          error_response({ error: res })
        else
          @course.reload
          @course.destroy if @course.branches.count.zero?
          success_response({ data: {}, message: I18n.t('courses.destroy') })
        end
      end

      private

      def set_course
        @course = Course.find_by_id(params[:id])

        error_response({ error: I18n.t('courses.record_not_found') }) if @course.nil?
      end

      def create_branch_and_semesters
        @branch = @course.branches.find_or_initialize_by(branch_params.except(:number_of_semesters))
        number_of_semesters = branch_params[:number_of_semesters].to_i

        return 'Operation already performed' if @branch.number_of_semesters == number_of_semesters

        @branch.number_of_semesters = number_of_semesters

        return @branch.errors.full_messages.join(', ') unless @branch.valid?

        @branch.save
      end

      def course_params
        params.require(:course).permit(:name)
      end

      def branch_params
        params.require(:branch).permit(:name, :number_of_semesters, :code)
      end

      def destroy_branch
        @branch = @course.branches.find_by(branch_params.except(:number_of_semesters))
        return @branch.destroy if @branch.present?

        I18n.t('branches.record_not_found')
      end

      def courses_response
        { data: { courses: @courses }, message: I18n.t('courses.index') }
      end
    end
  end
end
