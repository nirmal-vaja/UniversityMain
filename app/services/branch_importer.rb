# frozen_string_literal: true

# app/services/branch_importer.rb
class BranchImporter
  def initialize(data)
    @data = data
  end

  def create_course_and_branch # rubocop:disable Metrics/PerceivedComplexity,Metrics/CyclomaticComplexity,Metrics/AbcSize,Metrics/MethodLength
    headers = nil
    courses_cache = {}

    @data.each do |row|
      next if row.compact.empty?

      headers ||= construct_header(row)

      return { error: 'Upload valid file' } unless headers.include?('branch_code')

      if row[headers.find_index('branch_code')].is_a?(String) && row[headers.find_index('branch_code')].gsub(/\s+/, '').underscore == 'branch_code' # rubocop:disable Layout/LineLength
        next
      end

      branch_data = Hash[headers.zip(row)]

      course = courses_cache[branch_data['course']] ||= Course.find_or_initialize_by(name: branch_data['course'])

      return { error: "#{branch_data['course']} not found" } unless course

      return { error: course.errors.full_messages.join(', ') } if course.new_record? && course.errors.any?

      result = process_branch_data(course, branch_data, courses_cache)

      return result if result.is_a?(Hash) && result.key?(:error)
    end

    { data: {}, message: I18n.t('excel_sheets.created') }
  end

  private

  def construct_header(row)
    row.compact.map { |header| header.gsub(/\s+/, '').underscore }
  end

  def process_code(code)
    if code.is_a?(Float)
      code.to_i.to_s
    else
      code
    end
  end

  def process_branch_data(course, data, courses_cache) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    code = process_code(data['branch_code'])
    number_of_semesters = data['semesters'].to_i

    branch = course.branches.find_or_initialize_by(name: data['branch'], code:)

    return { branch:, skipped: true } if branch.number_of_semesters == number_of_semesters

    branch.number_of_semesters = number_of_semesters

    unless branch.valid?
      return { error: "#{course.name} - #{data['branch']} 
      " + branch.errors.full_messages.join(', ') }
    end

    courses_cache[course.name] = course

    branch.save
  end
end
