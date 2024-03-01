class AddFieldsToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :department, :string
    add_column :users, :date_of_joining, :datetime
    add_reference :users, :course, foreign_key: true
    add_reference :users, :branch, foreign_key: true
    add_column :users, :user_type, :integer
    add_column :users, :otp, :string
    add_column :users, :otp_generated_at, :datetime
    add_column :users, :show, :boolean
    add_column :users, :secure_id, :text
  end
end
