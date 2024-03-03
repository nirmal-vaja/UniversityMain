# frozen_string_literal: true

# ExcelImporter
class ExcelImporter # rubocop:disable Metrics/ClassLength
  def initialize(sheet_attachment)
    @sheet_attachment = sheet_attachment
  end

  def create_course_and_branch # rubocop:disable Metrics/CyclomaticComplexity,Metrics/AbcSize,Metrics/MethodLength
    data = open_sheet_file
    headers = nil

    data.each do |row|
      next if row.compact.empty?

      headers ||= construct_header(row)

      next if row[0] == 'Sr. no'

      cb_data = Hash[headers.zip(row)]

      course = Course.find_or_initialize_by(name: cb_data['course'])
      res = create_branch(course, cb_data)

      return { error: course.errors.full_messages } if course.new_record? && course.errors.any?

      return { error: res, display_message: true } if res.is_a?(String)
    end

    { data: {}, message: I18n.t('excel_sheets.created') }
  end

  def create_semester_details # rubocop:disable Metrics/AbcSize,Metrics/MethodLength,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
    data = open_sheet_file
    headers = nil

    data.each do |row|
      next if row.compact.empty?

      headers ||= construct_header(row)

      next if row[0] == 'Sr. no'

      sd_data = Hash[headers.zip(row)]

      semester = find_semester(sd_data)

      return semester if semester.is_a?(Hash) && semester&.key?(:error)

      next if semester.number_of_divisions == sd_data['no_of_divisions'].to_i

      next if semester.update(number_of_divisions: sd_data['no_of_divisions'].to_i)
    end

    { message: I18n.t('excel_sheets.created') }
  end

  def create_subjects # rubocop:disable Metrics/MethodLength
    data = open_sheet_file
    headers = nil

    data.each do |row|
      next if row.compact.empty?

      headers ||= construct_header(row)

      next if row[0] == 'Sr no.'

      subject_data = Hash[headers.zip(row)]

      subject = find_or_initialize_subject(subject_data)
      return subject if subject.is_a?(Hash) && subject.key?(:error)
    end

    { message: I18n.t('excel_sheets.created') }
  end

  def create_faculties # rubocop:disable Metrics/MethodLength
    data = open_sheet_file
    headers = nil
    data.each do |row|
      next if row.compact.empty?

      headers ||= construct_header(row)

      next if row[0] == 'Sr. no'

      faculty_data = Hash[headers.zip(row)]

      user = find_or_initialize_faculty(faculty_data)
      return user if user.is_a?(Hash) && user.key?(:error)
    end

    { message: I18n.t('excel_sheets.created') }
  end

  private

  def find_or_initialize_faculty(data) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength,Metrics/CyclomaticComplexity
    course = Course.find_by_name(data['course'])
    return { error: "#{data['course']} not found" } unless course

    branch = course.branches.find_by_name(data['department'])
    return { error: "#{data['department']} not found in #{course.name}" } unless branch

    User.find_or_initialize_by(email: data['email']).tap do |u|
      u.first_name = data['faculty_name'].split(' ')[0]
      u.last_name = data['faculty_name'].split(' ')[1]
      u.mobile_number = data['mobile_number'].to_i
      u.designation = data['designation']
      u.date_of_joining = data['dateof_joining']
      u.gender = data['gender'].downcase
      u.status = true
      u.department = data['designation']
      u.course = course
      u.branch = branch
      u.password = 'password' unless u.persisted?
      u.user_type = data['type'] == 'Junior' ? 0 : 1
      u.add_role(:faculty) unless u.persisted?
      u.secure_id = SecureRandom.hex(7) unless u.persisted?
      return { error: "#{data['faculty_name']}'s " + u.errors.full_messages.join(', ') } unless u.save
    end
  end

  def find_or_initialize_subject(data) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    course = Course.find_by(name: data['course'])
    return { error: "#{data['course']} not found" } unless course

    branch = course.branches.find_by(name: data['branch'])
    return { error: "#{data['branch']} not found in #{course.name}" } unless branch

    semester = branch.semesters.find_by_number(data['semester'])
    return { error: "Semester - #{data['semester']} not found in #{course.name} #{branch.name}" } unless semester

    semester.subjects.find_or_initialize_by(code: data['subject_code'].to_i).tap do |s|
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

  def create_branch(course, data)
    branch = course.branches.find_or_initialize_by(name: data['branch'], code: data['branch_code'].to_i.to_s)

    number_of_semesters = data['semesters'].to_i

    return if branch.number_of_semesters == number_of_semesters

    branch.number_of_semesters = number_of_semesters

    return { error: branch.errors.full_messages.join(', ') } unless branch.valid?

    branch.save
  end

  def find_semester(sd_data)
    course = Course.find_by_name(sd_data['course'])
    return { error: "#{sd_data['course']} not found" } unless course

    branch = course.branches.find_by_name(sd_data['branch'])
    return { error: "#{sd_data['branch']} not found in #{course.name}" } unless branch

    semester = branch.semesters.find_by_number(sd_data['semester'].to_i)
    { error: "Semester - #{sd_data['semester']} not found in #{course.name}, #{branch.name}" } unless semester

    semester
  end

  def construct_header(row)
    row.compact.map { |header| header.gsub(/\s+/, '').underscore }
  end

  def open_sheet_file
    Roo::Spreadsheet.open(create_temp_file)
  end

  def create_temp_file
    file_name = @sheet_attachment.blob.filename
    @tmp = Tempfile.new([file_name.base, file_name.extension_with_delimiter], binmode: true)
    @tmp.write(@sheet_attachment.download)
    @tmp.rewind
    @tmp
  end
end
