# frozen_string_literal: true

# app/models/student_block.rb
class StudentBlock < ApplicationRecord
  belongs_to :examination_block
  belongs_to :student
  belongs_to :course
  belongs_to :branch
end
