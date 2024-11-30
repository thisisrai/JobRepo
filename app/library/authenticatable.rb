module Authenticatable
  extend ActiveSupport::Concern

  AUTHORIZED_EMAILS = ['thisisrailee@gmail.com', 'kavin@coffeejob.io'].freeze

  private

  def authenticate_admin!
    return true if Rails.env.test?

    unless current_user && AUTHORIZED_EMAILS.include?(current_user.username)
      render json: { error: 'Unauthorized access' }, status: :unprocessable_entity
    end
  end

  def current_user
    @current_user ||= @user
  end
end