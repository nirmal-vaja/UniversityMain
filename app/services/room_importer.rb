# frozen_string_literal: true

# app/services/room_importer.rb
class RoomImporter
  def initialize(data)
    @data = data
  end

  def create_rooms
    headers = nil
    courses_cache = {}
    branches_cache = {}

    @data.each do |row|
      next if row.compact.empty?

      headers ||= construct_header(row)

      return { error: 'Upload valid file' } unless headers.include?('room_number')

      next if row[headers.find_index('room_number')].is_a?(String) && row[headers.find_index('room_number')].gsub(
        /\s+/, ''
      ).underscore == 'room_number'

      room_data = Hash[headers.zip(row)]

      result = process_room_data(room_data, courses_cache, branches_cache)

      return result if result.is_a?(Hash) && result.key?(:error)
      next if result.is_a?(String) && result.key?(:skipped)
    end

    { message: I18n.t('excel_sheets.created') }
  end

  private

  def construct_header(row)
    row.compact.map { |header| header.gsub(/\s+/, '').underscore }
  end

  def process_room_data(data, courses_cache, branches_cache)
    course, branch = find_course_and_branch(data, courses_cache, branches_cache)

    existing_room = find_existing_room(data, course, branch)
    return { room: existing_room, skipped: true } if existing_room

    create_or_initialize_room(data, course, branch)
  end

  def find_course_and_branch(data, courses_cache, branches_cache)
    course_name = data['course']
    branch_name = data['department']

    course = courses_cache[course_name] ||= Course.find_by(name: course_name)
    return { error: "#{course_name} not found" } unless course

    branch = branches_cache[branch_name] ||= course.branches.find_by(name: branch_name)
    return { error: "#{branch_name} not found in #{course_name}" } unless branch

    [course, branch]
  end

  def find_existing_room(data, course, branch)
    room = ExaminationRoom.find_by(
      course:,
      branch:,
      floor: data['floor'].to_i.to_s,
      room_number: data['room_number'].to_i.to_s,
      capacity: data['capacity']
    )

    return nil unless room

    room
  end

  def create_or_initialize_room(data, course, branch) # rubocop:disable Metrics/MethodLength
    room = ExaminationRoom.find_or_initialize_by(
      course:,
      branch:,
      floor: data['floor'].to_i.to_s,
      room_number: data['room_number'].to_i.to_s
    ) do |s|
      s.assign_attributes(
        capacity: data['capacity'].to_i
      )
    end

    return { error: room.errors.full_messages.join(', ') } unless room.save

    { room: }
  end
end
