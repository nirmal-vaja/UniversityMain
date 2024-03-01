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
end
