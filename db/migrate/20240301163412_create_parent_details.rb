class CreateParentDetails < ActiveRecord::Migration[7.0]
  def change
    create_table :parent_details do |t|
      t.string :qualification_of_father
      t.string :occupation_of_father
      t.string :father_company_name
      t.string :father_designation
      t.string :father_office_address
      t.string :father_annual_income
      t.string :father_professional_email
      t.string :qualification_of_mother
      t.string :mother_company_name
      t.string :mother_designation
      t.string :mother_office_address
      t.string :mother_annual_income
      t.string :mother_professional_email
      t.string :date_of_marriage
      t.references :student, null: false, foreign_key: true

      t.timestamps
    end
  end
end
