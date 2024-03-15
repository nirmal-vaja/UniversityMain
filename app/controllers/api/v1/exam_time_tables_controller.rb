# frozen_string_literal: true

module Api
  module V1
    # app/controllers/api/v1/exam_time_tables_controller.rb
    class ExamTimeTablesController < ApiController # rubocop:disable Metrics/ClassLength
      before_action :set_time_table, only: %i[update destroy]

      def index
        @time_tables = ExamTimeTable.without_default_scope.where(time_table_params).order(examination_date: :asc)
        success_response({ data: { exam_time_tables: @time_tables } })
      end

      def create # rubocop:disable Metrics/MethodLength
        @exam_time_table = ExamTimeTable.new(time_table_params)

        begin
          ActiveRecord::Base.transaction do
            create_block_wise_reports
            raise ActiveRecord::Rollback unless @exam_time_table.save

            generate_block_extra_configs
            generate_and_store_examination_blocks
            success_response({ message: I18n.t('exam_time_tables.created') })
          end
        rescue StandardError => e
          error_response({ error: e.message })
        end
      end

      def update
        if @time_table.update(time_table_params)
          generate_block_extra_configs
          success_response({ message: I18n.t('exam_time_tables.updated') })
        else
          error_response({ error: @time_tables.errors.full_messages.join(', ') })
        end
      end

      def destroy
        if @time_table.destroy
          success_response({ message: I18n.t('exam_time_tables.destroy') })
        else
          error_response({ error: @time_tables.errors.full_messages.join(', ') })
        end
      end

      def all_unique_exam_time_table
        @exam_time_tables = current_user.course.exam_time_tables.without_default_scope
                                        .distinct
                                        .order(examination_date: :asc)

        success_response({ data: { exam_time_tables: @exam_time_tables } })
      end

      def unique_examination_dates
        @exam_time_table_dates = ExamTimeTable.without_default_scope
                                              .distinct
                                              .where(time_table_params.except(:examination_date))
                                              .order(examination_date: :asc)
                                              .pluck(:examination_date)

        success_response({ data: { examination_dates: @exam_time_table_dates } })
      end

      def exam_related_subjects
        @time_tables = ExamTimeTable.includes(:subject).where(time_table_params)
        @subjects = @time_tables&.map(&:subject).presence

        if @subjects
          success_response({ data: { subjects: @subjects } })
        else
          error_response({ error: I18n.t('subjects.records_not_found') })
        end
      end

      def find_subjects_without_time_table
        @subjects = Subject.where(time_table_params.slice(:course_id, :branch_id, :semester_id))
        @subject_ids_to_exclude = ExamTimeTable.where(time_table_params)&.pluck(:subject_id)
        return success_response({ data: { subjects: @subjects } }) unless @subject_ids_to_exclude.present?

        @subjects = @subjects.where.not(id: @subject_ids_to_exclude)
        success_response({ data: { subjects: @subjects } })
      end

      # Move this code to blocks_controller.rb
      # def available_blocks
      #   @blocks = Block
      #             .includes(:students, :student_blocks)
      #             .where(block_params)
      #             .having_available_capacity
      #             .order(name: :asc)

      #   if @blocks.present?
      #     success_response({ data: { blocks: @blocks } })
      #   else
      #     error_response({ error: 'No available blocks found' })
      #   end
      # end

      private

      def set_time_table
        @time_table = ExamTimeTable.find_by_id(params[:id])
      end

      def time_table_params
        params.require(:exam_time_table).permit(:examination_name, :examination_type, :examination_time,
                                                :examination_date, :day, :academic_year, :course_id, :branch_id,
                                                :semester_id, :subject_id).to_h
      end

      def create_block_wise_reports # rubocop:disable Metrics/MethodLength
        @max_students_per_block = find_maximum_students_per_block
        number_of_students = find_no_students_appearing_for_this_exam

        @number_of_blocks = (number_of_students.to_f / @max_students_per_block).ceil

        @exam_time_table.build_time_table_block_wise_report(
          examination_name: @exam_time_table.examination_name,
          number_of_blocks: @number_of_blocks,
          academic_year: @exam_time_table.academic_year,
          number_of_students:,
          course_id: @exam_time_table.course_id,
          branch_id: @exam_time_table.branch_id,
          semester_id: @exam_time_table.semester_id,
          examination_type: @exam_time_table.examination_type
        )
      end

      def find_maximum_students_per_block
        ExaminationType.find_by_name(time_table_params[:examination_type]).max_students_per_block
      end

      def find_no_students_appearing_for_this_exam
        Student.where(branch_id: time_table_params[:branch_id], semester_id: time_table_params[:semester_id],
                      fees_paid: true).count
      end

      def examination_params
        {
          examination_date: @exam_time_table.examination_date,
          examination_time: @exam_time_table.examination_time,
          examination_name: @exam_time_table.examination_name,
          academic_year: @exam_time_table.academic_year,
          course_id: @exam_time_table.course_id,
          examination_type: @exam_time_table.examination_type
        }
      end

      def generate_and_store_examination_blocks # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
        return unless @exam_time_table.time_table_block_wise_report.present?

        name = get_next_block_name

        @number_of_blocks.times do
          block = @exam_time_table.examination_blocks.new(
            examination_name: @exam_time_table.examination_name,
            academic_year: @exam_time_table.academic_year,
            examination_type: @exam_time_table.examination_type,
            course_id: @exam_time_table.course_id,
            branch_id: @exam_time_table.branch_id,
            capacity: @max_students_per_block,
            name:,
            examination_date: @exam_time_table.examination_date,
            examination_time: @exam_time_table.examination_time,
            subject_id: @exam_time_table.subject_id
          )

          block.block_extra_config_id = @block_extra_config.id if block.block_extra_config_id.nil?

          block.save

          name = get_next_block_name(name)
        end
      end

      def get_next_block_name(current_block = nil)
        max_block = ExaminationBlock.where(examination_date: @exam_time_table.examination_date).maximum(:name)

        if max_block.nil?
          return 'A' unless current_block

          return current_block.succ
        end

        return max_block.succ unless current_block

        current_block.succ.upto(max_block) do |name|
          return name unless ExaminationBlock.exists?(examination_date: @exam_time_table.examination_date, name:)
        end
      end

      def generate_block_extra_configs
        total_number_of_blocks = ExamTimeTable
                                 .where(examination_params)
                                 .joins(:time_table_block_wise_report)
                                 .sum('time_table_block_wise_reports.number_of_blocks')

        @block_extra_config = BlockExtraConfig.find_or_initialize_by(examination_params)

        @block_extra_config.update(number_of_supervisions: total_number_of_blocks)
      end
    end
  end
end
