# app/mailers/user_mailer.rb
class UserMailer < ApplicationMailer
  default from: 'contact@coffeejob.io'

  def welcome_email(user)
    @user = user
    @url  = 'https://coffeejob.io'
    mail(to: @user.username, subject: 'Welcome to Our Service!')
  end
end

