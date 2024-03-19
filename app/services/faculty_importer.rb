# frozen_string_literal: true

# FacultyImporter
class FacultyImporter
  def initialize(data)
    @data = data
  end

  def create_faculties # rubocop:disable Metrics/AbcSize,Metrics/MethodLength,Metrics/PerceivedComplexity,Metrics/CyclomaticComplexity
    headers = nil
    courses_cache = {}
    branches_cache = {}

    @data.each do |row|
      next if row.compact.empty?

      headers ||= construct_header(row)
      next if row[0].to_i.zero?

      faculty_data = Hash[headers.zip(row)]
      result = process_faculty_data(faculty_data, courses_cache, branches_cache)

      return result if result.is_a?(Hash) && result.key?(:error)
      next if result.is_a?(Hash) && result.key?(:skipped)
    end

    { message: I18n.t('excel_sheets.created') }
  end

  private

  def construct_header(row)
    row.compact.map { |header| header.gsub(/\s+/, '').underscore }
  end

  def process_faculty_data(data, courses_cache, branches_cache)
    course, branch = find_course_and_branch(data, courses_cache, branches_cache)

    existing_user = find_existing_user(data, course, branch)
    return { user: existing_user, skipped: true } if existing_user

    create_or_initialize_user(data, course, branch)
  end

  def find_course_and_branch(data, courses_cache, branches_cache)
    course_name = data['course']
    department_name = data['department']
    course = courses_cache[course_name] ||= Course.find_by(name: course_name)
    return { error: "#{course_name} not found" } unless course

    branch = branches_cache["#{course_name}_#{department_name}"] ||= course.branches.find_by(name: department_name)
    return { error: "#{department_name} not found in #{course_name}" } unless branch

    courses_cache[course_name] = course
    branches_cache["#{course_name}_#{department_name}"] = branch

    [course, branch]
  end

  def find_existing_user(data, course, branch) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
    User.find_by(
      email: data['email'],
      first_name: data['faculty_name'].split(' ', 2)[0],
      last_name: data['faculty_name'].split(' ', 2)[1],
      mobile_number: data['mobile_number'].to_i.to_s,
      designation: data['designation'],
      date_of_joining: data['dateof_joining'],
      gender: data['gender'].downcase,
      department: branch.name,
      course:,
      branch:,
      user_type: data['type'] == 'Junior' ? 0 : 1
    )
  end

  def create_or_initialize_user(data, course, branch) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    user = User.find_or_initialize_by(email: data['email']).tap do |u|
      u.assign_attributes(
        first_name: data['faculty_name'].split(' ', 2)[0],
        last_name: data['faculty_name'].split(' ', 2)[1],
        mobile_number: data['mobile_number'].to_i,
        designation: data['designation'],
        date_of_joining: data['dateof_joining'],
        gender: data['gender'].downcase,
        status: true,
        department: branch.name,
        course:,
        branch:,
        password: 'password',
        user_type: data['type'] == 'Junior' ? 0 : 1
      )

      u.add_role(:faculty) unless u.has_role?(:faculty)
      return { error: "#{data['faculty_name']}'s " + u.errors.full_messages.join(', ') } unless u.save
    end

    { user: }
  end
end
