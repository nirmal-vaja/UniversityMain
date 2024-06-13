# frozen_string_literal: true

# app/services/student_importer.rb
class StudentImporter
  def initialize(data)
    @data = data
  end

  def create_students # rubocop:disable Metrics/PerceivedComplexity,Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength
    headers = nil
    courses_cache = {}
    branches_cache = {}
    semesters_cache = {}
    divisions_cache = {}

    @data.each do |row|
      next if row.compact.empty?

      headers ||= construct_header(row)

      return { error: 'Upload valid file' } unless headers.include?('enrollment_number')

      if row[headers.find_index('enrollment_number')].is_a?(String) && row[headers.find_index('enrollment_number')].gsub( # rubocop:disable Layout/LineLength
        /\s+/, ''
      ).underscore == 'enrollment_number'
        next
      end

      student_data = Hash[headers.zip(row)]

      result = process_student_data(student_data, courses_cache, branches_cache, semesters_cache, divisions_cache)

      return result if result.is_a?(Hash) && result.key?(:error)

      next if result.is_a?(Hash) && result.key?(:skipped)
    end

    { message: I18n.t('excel_sheets.created') }
  end

  private

  def construct_header(row)
    row.compact.map { |header| header.gsub(/\s+/, '').underscore }
  end

  def process_student_data(data, courses_cache, branches_cache, semesters_cache, divisions_cache)
    course, branch, semester, division = find_course_branch_semester_and_division(data, courses_cache, branches_cache,
                                                                                  semesters_cache, divisions_cache)
    return course if course.is_a?(Hash) && course.key?(:error)

    existing_student = find_existing_student(data, course, branch, semester, division)
    return { student: existing_student, skipped: true } if existing_student

    create_or_initialize_student(data, course, branch, semester, division)
  end

  def find_course_branch_semester_and_division(data, courses_cache, branches_cache, semesters_cache, divisions_cache) # rubocop:disable Metrics/PerceivedComplexity,Metrics/CyclomaticComplexity,Metrics/AbcSize,Metrics/MethodLength
    course_name = data['course']
    branch_name = data['branch']
    semester_number = data['semester'].to_i
    division_name = "Division #{data['division']}"

    course = courses_cache[course_name] ||= Course.find_by(name: course_name)

    return { error: "#{course_name} not found" } unless course.present?

    branch = branches_cache["#{course_name}_#{branch_name}"] ||= course.branches.find_by(name: branch_name)
    return { error: "#{branch_name} not found in #{course_name}" } unless branch.present?

    semester = semesters_cache["#{course_name}_#{branch_name}_#{semester_number}"] ||= branch.semesters.find_by(number: semester_number) # rubocop:disable Layout/LineLength

    unless semester.present?
      return { error: "Semester - #{semester_number} not found in #{course_name} #{branch_name}" }
    end

    division = divisions_cache["#{course_name}_#{branch_name}_#{semester_number}_#{division_name}"] ||= semester.divisions.find_by(name: division_name) # rubocop:disable Layout/LineLength

    unless division.present?
      return { error: "#{division_name} not found in #{semester.name} in #{course_name} #{branch_name}" }
    end

    courses_cache[course_name] = course
    branches_cache["#{course_name}_#{branch_name}"] = branch
    semesters_cache["#{course_name}_#{branch_name}_#{semester_number}"] = semester
    divisions_cache["#{course_name}_#{branch_name}_#{semester_number}_#{division_name}"] = division

    [course, branch, semester, division]
  end

  def find_existing_student(data, course, branch, semester, division) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    student = Student.find_by(
      name: data['name'],
      enrollment_number: data['enrollment_number'].to_i.to_s,
      course_id: course.id,
      branch_id: branch.id,
      semester_id: semester.id,
      division_id: division.id,
      fees_paid: data['fees_paid'].to_i.zero? ? false : true,
      gender: data['gender'].downcase,
      father_name: data["father's_full_name"],
      mother_name: data["mother's_full_name"],
      date_of_birth: data['dateof_birth'],
      birth_place: data['birth_place'],
      religion: data['religion'],
      caste: data['caste'],
      blood_group: data['blood_group']
    )

    contact_detail = Student.joins(:contact_detail).where(mobile_number: data['mobile_number'].to_i,
                                                          personal_email_address: data['email_address'], student_id: student.id)&.contact_detail

    return nil unless contact_detail

    student
  end

  def create_or_initialize_student(data, course, branch, semester, division) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    student = Student.find_or_initialize_by(enrollment_number: data['enrollment_number'].to_i.to_s) do |s|
      s.assign_attributes(
        name: data['name'],
        course_id: course.id,
        branch_id: branch.id,
        semester_id: semester.id,
        division_id: division.id,
        fees_paid: data['fees_paid'].to_i.zero? ? false : true,
        gender: data['gender'].downcase,
        father_name: data["father's_full_name"],
        mother_name: data["mother's_full_name"],
        date_of_birth: data['dateof_birth'],
        birth_place: data['birth_place'],
        religion: data['religion'],
        caste: data['caste'],
        blood_group: data['blood_group']
      )
    end

    contact_detail_attributes = {
      mobile_number: data['mobile_number'].to_i,
      personal_email_address: data['email_address']
    }

    if student.new_record?
      student.build_contact_detail(contact_detail_attributes)
    else
      student.contact_detail.update(contact_detail_attributes)
    end

    return { error: student.errors.full_messages.join(', ') } unless student.save

    { student: }
  end
end
