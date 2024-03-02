# frozen_string_literal: true

# User Model
class User < ApplicationRecord
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, message: 'is not a valid email address' }
  validates :mobile_number,
            format: { with: /\A(?:\+?\d{1,3}[-.●]?)?\d{9,15}\z/, message: 'is not a valid mobile number' }

  # Associations
  belongs_to :course, optional: true
  belongs_to :branch, optional: true

  before_create :set_department

  enum :gender, { male: 0, female: 1 }
  enum user_type: { "Junior": 0, "Senior": 1 }

  # the authenticate method from devise documentation
  def self.authenticate(email, password)
    user = User.find_for_authentication(email:)
    user&.valid_password?(password) ? user : nil
  end

  private

  def set_department
    self.department = branch.name
  end
end
