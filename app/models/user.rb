# frozen_string_literal: true

# User Model
class User < ApplicationRecord
  include DefaultJsonOptions
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

  enum :gender, { male: 0, female: 1 }
  enum user_type: { "Junior": 0, "Senior": 1 }

  # def as_json(options = {})
  #   options[:except] ||= %i[show secure_id otp otp_generated_at status date_of_joining]
  #   options[:methods] ||= %i[full_name modified_date_of_joining course_name branch_name]
  #   super(options)
  # end

  def branches
    course.branches
  end

  def modified_date_of_joining
    date_of_joining&.strftime('%Y/%m/%d')
  end

  def remove_role_without_deletion(role_name)
    role = Role.find_by_name(role_name)
    roles.delete(role)
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def course_name
    course&.name
  end

  def branch_name
    branch&.name
  end

  def send_role_assigned_notification(extra_params = {})
    UserMailer.role_assigned_notification(self, extra_params).deliver_now
  end

  def find_role_other_than_faculty
    roles.where.not(name: 'faculty').first
  end

  def generate_otp
    self.otp = [1, 2, 3, 4, 5, 6, 7, 8, 9].sample(6).join('')
    self.otp_generated_at = Time.current
    save
  end

  def send_otp_email
    UserMailer.send_otp_mail(self).deliver_now
  end

  def valid_otp?(otp)
    self.otp == otp
  end

  def generate_doorkeeper_token
    Doorkeeper::AccessToken.create!(
      resource_owner_id: id,
      application_id: Doorkeeper::Application.first.id,
      expires_in: Doorkeeper.configuration.access_token_expires_in,
      scopes: Doorkeeper.configuration.default_scopes
    )
  end

  # the authenticate method from devise documentation
  def self.authenticate(email, password, otp = nil) # rubocop:disable Metrics/MethodLength,Metrics/PerceivedComplexity
    user = User.find_for_authentication(email:)
    if user
      if otp.nil?
        user.valid_password?(password) ? user : nil
      else
        role = user.find_role_other_than_faculty
        if role
          @user = if role.name == 'Marks Entry' # rubocop:disable Metrics/BlockNesting
                    user
                  else
                    User.where(course_id: user.course_id).with_role(role.name).last
                  end
          if @user.valid_otp?(otp) # rubocop:disable Metrics/BlockNesting
            @user.generate_doorkeeper_token
            user
          end
        end
      end
    else # rubocop:disable Style/EmptyElse
      nil
    end
  end

  private

  def default_json_options(options)
    super(options).merge(
      except: super[:except].push(:show, :secure_id, :otp, :otp_generated_at, :status, :date_of_joining),
      methods: super[:methods].push(:full_name, :modified_date_of_joining, :course_name, :branch_name)
    )
  end
end
