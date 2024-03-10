# frozen_string_literal: true

# app/services/semester_importer.rb
class SemesterImporter
  def initialize(data)
    @data = data
  end

  def update_semesters # rubocop:disable Metrics/PerceivedComplexity,Metrics/CyclomaticComplexity,Metrics/AbcSize,Metrics/MethodLength
    headers = nil
    courses_cache = {}
    branches_cache = {}
    semesters_cache = {}

    @data.each do |row|
      next if row.compact.empty?

      headers ||= construct_header(row)
      next if row[0].to_i.zero?

      semester_data = Hash[headers.zip(row)]

      result = process_semester_data(semester_data, courses_cache, branches_cache, semesters_cache)

      return result if result.is_a?(Hash) && result.key?(:error)

      number_of_divisions = semester_data['no_of_divisions'].to_i

      next if result.number_of_divisions == number_of_divisions

      next if result.update(number_of_divisions:)
    end

    { message: I18n.t('excel_sheets.created') }
  end

  private

  def construct_header(row)
    row.compact.map { |header| header.gsub(/\s+/, '').underscore }
  end

  def process_semester_data(data, courses_cache, branches_cache, semesters_cache)
    find_course_branch_and_semester(data, courses_cache, branches_cache, semesters_cache)
  end

  def find_course_branch_and_semester(data, courses_cache, branches_cache, semesters_cache) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    course_name = data['course']
    branch_name = data['branch']
    semester_number = data['semester'].to_i

    course = courses_cache[course_name] ||= Course.find_by(name: course_name)
    return { error: "#{course_name} not found" } unless course

    branch = branches_cache["#{course_name}_#{branch_name}"] ||= course.branches.find_by(name: branch_name)
    return { error: "#{branch_name} not found in #{course_name}" } unless branch

    semester = semesters_cache["#{course_name}_#{branch_name}_#{semester_number}"] ||= branch.semesters.find_by_number(semester_number) # rubocop:disable Layout/LineLength

    return { error: "Semester - #{semester_number} not found in #{course_name} #{branch_name}" } unless semester

    courses_cache[course_name] = course
    branches_cache["#{course_name}_#{branch_name}"] = branch
    semesters_cache["#{course_name}_#{branch_name}_#{semester_number}"] = semester

    semester
  end
end
