class PasswordResetMailer < ApplicationMailer
  default from: 'contact@coffeejob.io'


  def reset_email(user)
    @user = user
    @token = @user.reset_password_token

    mail(to: @user.username, subject: 'Password Reset Instructions')
  end
end
