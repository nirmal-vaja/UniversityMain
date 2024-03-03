# frozen_string_literal: true

# ExcelSheetPolicy
class ExcelSheetPolicy < ApplicationPolicy
  def create?
    user.has_role?(:super_admin)
  end
end
