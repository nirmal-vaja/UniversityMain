# frozen_string_literal: true

# app/services/subject_importer.rb
class SubjectImporter
  def initialize(data)
    @data = data
  end

  def create_subjects # rubocop:disable Metrics/AbcSize,Metrics/PerceivedComplexity,Metrics/CyclomaticComplexity,Metrics/MethodLength
    headers = nil
    courses_cache = {}
    branches_cache = {}
    semesters_cache = {}

    @data.each do |row|
      next if row.compact.empty?

      headers ||= construct_header(row)
      next if row[0].to_i.zero?

      subject_data = Hash[headers.zip(row)]
      result = process_subject_data(subject_data, courses_cache, branches_cache, semesters_cache)

      return result if result.is_a?(Hash) && result.key?(:error)
      next if result.is_a?(Hash) && result.key?(:skipped)
    end

    { message: I18n.t('excel_sheets.created') }
  end

  private

  def construct_header(row)
    row.compact.map { |header| header.gsub(/\s+/, '').underscore }
  end

  def process_subject_data(data, courses_cache, branches_cache, semesters_cache)
    course, branch, semester = find_course_branch_and_semester(data, courses_cache, branches_cache, semesters_cache)

    existing_subject = find_existing_subject(data, course, branch, semester)
    return { subject: existing_subject, skipped: true } if existing_subject

    create_or_initialize_subject(data, course, branch, semester)
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

    [course, branch, semester]
  end

  def find_existing_subject(data, course, branch, semester) # rubocop:disable Metrics/MethodLength
    Subject.find_by(
      code: data['subject_code'],
      name: data['subject_name'],
      semester:,
      branch:,
      course:,
      category: data['category'],
      lecture: data['lecture'].to_i,
      tutorial: data['tutorial'].to_i,
      practical: data['practical'].to_i
    )
  end

  def create_or_initialize_subject(data, course, branch, semester) # rubocop:disable Metrics/AbcSize
    semester.subjects.find_or_initialize_by(code: data['subject_code']).tap do |s|
      s.name = data['subject_name']
      s.course = course
      s.branch = branch
      s.category = data['category']
      s.lecture = data['lecture'].to_i
      s.tutorial = data['tutorial'].to_i
      s.practical = data['practical'].to_i

      return { error: s.errors.full_messages.join(', ') } unless s.save
    end
  end
end
