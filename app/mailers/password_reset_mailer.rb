class PasswordResetMailer < ApplicationMailer
  def reset_email
    @user = params[:user]
    @reset_url = password_reset_url(token: @user.reset_password_token)

    mail(to: @user.username, subject: 'Password Reset Instructions')
  end
end
