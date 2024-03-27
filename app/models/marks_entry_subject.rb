# frozen_string_literal: true

# app/models/marks_entry_subject.rb
class MarksEntrySubject < ApplicationRecord
  belongs_to :marks_entry
  belongs_to :subject
end
