class ApplicationController < ActionController::API
  before_action :authorized

  def encode_token(payload)
    JWT.encode(payload, ENV['BACKEND_DATABASE_PASSWORD'] || 'dev')
  end

  def auth_header
    request.headers['Authorization']
  end

  def decoded_token
    if auth_header
      token = auth_header.split(' ')[1]
      begin
          JWT.decode(token, ENV['BACKEND_DATABASE_PASSWORD'] || 'dev', true, algorithm: 'HS256')
      rescue JWT::DecodeError
        nil
      end
    end
  end

  def logged_in_user
    if decoded_token
      user_id = decoded_token[0]['user_id']
      @user = User.find_by(id: user_id)
    end
  end

  def logged_in?
    !!logged_in_user
  end

  def current_user
    @user
  end

  def authorized
    render json: { message: 'Please log in'}, status: :unauthorized unless (logged_in? || Rails.env.test?)
  end
end
