class CreateStudents < ActiveRecord::Migration[7.0]
  def change
    create_table :students do |t|
      t.string :name
      t.string :enrollment_number
      t.references :course, null: false, foreign_key: true
      t.references :branch, null: false, foreign_key: true
      t.references :semester, null: false, foreign_key: true
      t.boolean :fees_paid, default: false
      t.string :gender
      t.string :father_name
      t.string :mother_name
      t.string :date_of_birth
      t.string :birth_place
      t.string :religion
      t.string :caste
      t.string :nationality
      t.string :mother_tongue
      t.string :marrital_status
      t.string :blood_group
      t.boolean :physically_handicapped
      t.string :otp
      t.datetime :otp_generated_at
      t.references :division, null: false, foreign_key: true

      t.timestamps
    end
  end
end
