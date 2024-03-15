# frozen_string_literal: true

# ExcelImporter
class ExcelImporter
  def initialize(sheet_attachment)
    @sheet_attachment = sheet_attachment
    @data = open_sheet_file
    @branch_importer = BranchImporter.new(@data)
    @semester_importer = SemesterImporter.new(@data)
    @faculty_importer = FacultyImporter.new(@data)
    @subject_importer = SubjectImporter.new(@data)
    @student_importer = StudentImporter.new(@data)
    @room_importer = RoomImporter.new(@data)
  end

  def import_branches
    @branch_importer.create_course_and_branch
  end

  def import_semesters
    @semester_importer.update_semesters
  end

  def import_subjects
    @subject_importer.create_subjects
  end

  def import_faculties
    @faculty_importer.create_faculties
  end

  def import_students
    @student_importer.create_students
  end

  def import_rooms
    @room_importer.create_rooms
  end

  private

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
