class CreateContactDetails < ActiveRecord::Migration[7.0]
  def change
    create_table :contact_details do |t|
      t.string :mobile_number
      t.string :emergency_mobile_number
      t.string :residence_phone_number
      t.string :personal_email_address
      t.string :university_email_address
      t.string :fathers_mobile_number
      t.string :fathers_personal_email
      t.string :mothers_mobile_number
      t.string :mothers_personal_email
      t.references :student, null: false, foreign_key: true

      t.timestamps
    end
  end
end
