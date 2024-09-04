class PasswordResetsController < ApplicationController
  # POST /password_resets
  def create
    user = User.find_by(username: params[:username])

    if user
      user.generate_password_reset_token! # Custom method on User model to generate token
      PasswordResetMailer.with(user: user).reset_email.deliver_later
      render json: { message: 'Password reset email will be sent shortly.' }, status: :ok
    else
      render json: { error: 'Email not found.' }, status: :not_found
    end
  end

  # PUT /password_resets/:token
  def update
    user = User.find_by(reset_password_token: params[:token])

    if user&.reset_password_period_valid?
      if user.update(password_params)
        user.clear_password_reset_token!
        render json: { message: 'Password successfully updated.' }, status: :ok
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: 'Invalid or expired token.' }, status: :unprocessable_entity
    end
  end

  private

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end