# frozen_string_literal: true

module Api
  module V1
    # app/controllers/api/v1/blocks_controller.rb
    class ExaminationBlocksController < ApiController
      before_action :set_block, only: %i[assign_students update delete_all_students assign_room]

      def index
        @blocks = ExaminationBlock.joins(:subject)
                                  .where(examination_block_params)
                                  .where.not(number_of_students: 0)
                                  .order('subjects.name, name')
        success_response({ data: { blocks: @blocks } })
      end

      def available_blocks
        @blocks = @blocks = ExaminationBlock
                            .includes(:students, :student_blocks)
                            .where(block_params)
                            .having_available_capacity
                            .order(name: :asc)

        success_response({ data: { blocks: @blocks } })
      end

      def available_blocks_to_assign_room
        @blocks = ExaminationBlock
                  .with_students_and_no_rooms
                  .where(block_params)

        success_response({ data: { blocks: @blocks } })
      end

      def blocks_for_blocks_to_room
        @blocks = ExaminationBlock
                  .with_students_and_rooms
                  .where(block_params)

        @blocks = @blocks.map do |block|
          examination_room = block.examination_rooms.first
          block.attributes.merge({
                                   room: examination_room,
                                   room_number: examination_room.room_number
                                 })
        end

        success_response({ data: { blocks: @blocks } })
      end

      def assign_room
        room_block = @block.room_blocks.new(
          examination_name: block_params[:examination_name],
          examination_time: block_params[:examination_time],
          examination_type: block_params[:examination_type],
          examination_date: block_params[:examination_date],
          academic_year: block_params[:academic_year],
          course_id: block_params[:course_id],
          branch_id: block_params[:branch_id],
          examination_room_id: block_params[:room_id],
          occupied: @block.number_of_students
        )

        if room_block.save
          success_response({ message: 'Block has been assigned successfully.' })
        else
          error_response({ error: room_block.errors.full_messages.join(', ') })
        end
      end

      def update
        @block.students.clear
        if @block.student_ids << params[:student_ids]
          @block.update(number_of_students: @block.students.count)
          success_response({ message: 'Operation successful' })
        else
          error_response({ error: @block.errors.full_messages.join(', ') })
        end
      end

      def assign_students
        @students = Student.where(id: params[:student_ids])

        error_response({ error: 'No valid students selected.' }) unless valid_students?

        error_response({ error: 'Assignment failed. Capacity exceeded.' }) if capacity_exceeded?

        ActiveRecord::Base.transaction do
          if assign_students_to_block
            success_response({ message: "Students successfully assigned to #{@block.name}" })
          else
            error_response({ error: 'Error assigning students to the block' })
            raise ActiveRecord::Rollback
          end
        end
      end

      def delete_all_students
        if @block.student_blocks.destroy_all
          @block.update(number_of_students: 0)
          success_response({ message: 'All students have been unassigned from the block successfully.' })
        else
          error_response({ error: @block.errors.full_messages.join(', ') })
        end
      end

      def delete_all_rooms
        if @block.room_blocks.destroy_all
          success_response({ message: 'Block has been removed from the room successfully.' })
        else
          error_response({ error: @block.errors.full_messages.join(', ') })
        end
      end

      private

      def examination_block_params
        params.require(:block).permit(
          :examination_name,
          :academic_year,
          :examination_time,
          :examination_type,
          :course_id,
          :branch_id,
          :examination_date,
          student_ids: [],
          room_ids: []
        )
      end

      def set_block
        @block = ExaminationBlock.find_by(id: params[:id])
        error_response({ error: 'No block found' }) unless @block
      end

      def valid_students?
        @students.present?
      end

      def capacity_exceeded?
        @students.count + @block.students.count > @block.capacity
      end

      def assign_students_to_block
        @block.student_ids = @students.pluck(:id)
        @block.reload
        @block.update(number_of_students: @block.students.count)
      end

      def block_params
        params.require(:block).permit(
          :examination_name,
          :academic_year,
          :examination_type,
          :examination_time,
          :examination_date,
          :course_id,
          :branch_id,
          :room_id
        ).to_h
      end
    end
  end
end
