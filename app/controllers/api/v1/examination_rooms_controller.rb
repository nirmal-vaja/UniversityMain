# frozen_string_literal: true

module Api
  module V1
    # ExaminationRooms Controller
    class ExaminationRoomsController < ApiController
      def unoccupied_rooms
        block_capacity = params[:block_capacity]
        @no_room_blocks_rooms = ExaminationRoom.left_outer_joins(:room_blocks)
                                               .where(room_blocks: { id: nil })
        @available_rooms = ExaminationRoom.joins(:room_blocks)
                                          .where(room_blocks: {
                                                   examination_name: params[:room][:examination_name],
                                                   examination_time: params[:room][:examination_time],
                                                   examination_type: params[:room][:examination_type],
                                                   examination_date: params[:room][:examination_date],
                                                   course_id: params[:room][:course_id],
                                                   branch_id: params[:room][:branch_id]
                                                 })
                                          .group('examination_rooms.id')
                                          .having('examination_rooms.capacity - SUM(room_blocks.occupied) > ?', block_capacity)

        @rooms = @no_room_blocks_rooms + @available_rooms
        @rooms = @rooms.sort_by(&:room_number)
        success_response({ data: { rooms: @rooms } })
      end

      private

      def room_params
        params.require(:room).permit(:course_id, :branch_id).to_h
      end
    end
  end
end
