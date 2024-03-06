# frozen_string_literal: true

# UserMailer
class UserMailer < ApplicationMailer
  def send_university_registration_mail(email, university, url, token)
    @email = email
    @university = university
    @url = url
    @token = token
    mail(to: @email, subject: "#{@university} has been registered.")
  end

  def role_assigned_notification(user, opts = {})
    @user = user
    @role_name = opts[:role_name]
    @url = opts[:url]
    mail(to: @user.email, subject: "You have been assigned as #{@role_name}!")
  end

  def send_otp_mail(user)
    @user = user
    mail(to: @user.email, subject: 'You recieved an OTP')
  end
end
