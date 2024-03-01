class CreateAddressDetails < ActiveRecord::Migration[7.0]
  def change
    create_table :address_details do |t|
      t.text :current_address_1
      t.text :current_address_2
      t.string :current_address_area
      t.string :current_address_country
      t.string :current_address_state
      t.string :current_address_city
      t.string :current_address_pincode
      t.text :permanent_address_1
      t.text :permanent_address_2
      t.string :permanent_address_area
      t.string :permanent_address_country
      t.string :permanent_address_city
      t.string :permanent_address_pincode
      t.references :student, null: false, foreign_key: true

      t.timestamps
    end
  end
end
