class CreateGuardianDetails < ActiveRecord::Migration[7.0]
  def change
    create_table :guardian_details do |t|
      t.string :name
      t.string :relation
      t.string :mobile_number
      t.string :personal_email
      t.string :professional_email
      t.text :address_1
      t.text :address_2
      t.string :area
      t.string :country
      t.string :state
      t.string :city
      t.string :pincode
      t.references :student, null: false, foreign_key: true

      t.timestamps
    end
  end
end
