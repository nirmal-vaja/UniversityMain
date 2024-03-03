# frozen_string_literal: true

module Api
  module V1
    # ExcelSheetsController
    class ExcelSheetsController < ApiController
      def index
        @excel_sheets = ExcelSheet.all
        success_response({ data: { excel_sheets: @excel_sheets }, message: I18n.t('excel_sheets.index') })
      end

      def create # rubocop:disable Metrics/MethodLength
        @excel_sheet = ExcelSheet.find_or_initialize_by(excel_sheet_params.except(:sheet))
        authorize @excel_sheet
        @excel_sheet.sheet = excel_sheet_params[:sheet]
        if @excel_sheet.save
          res = run_creater
          if res.key?(:error)
            error_response(res)
          else
            success_response(res)
          end
        else
          error_response({ message: @excel_sheet.errors.full_messages.join(', ') })
        end
      end

      private

      def run_creater # rubocop:disable Metrics/MethodLength,Metrics/AbcSize,Metrics/CyclomaticComplexity
        if @excel_sheet.sheet.attached?
          importer = ExcelImporter.new(@excel_sheet.sheet)
          case @excel_sheet.name
          when 'Course and Branch Details'
            importer.create_course_and_branch
          when 'Semester and Division Details'
            importer.create_semester_details
          when 'Subject Details'
            importer.create_subjects
          when 'Faculty Details'
            importer.create_faculties
          when 'Student Details'
            importer.create_students
          when 'Room Details'
            importer.create_rooms
          when 'Syllabus Details'
            importer.create_syllabus
          end
        else
          { error: @excel_sheet.errors.full_messages.join(', ') }
        end
      end

      def excel_sheet_params
        params.require(:excel_sheet).permit(:name, :sheet)
      end
    end
  end
end
