class HealthcheckController < ApplicationController

  def authorized
  end

  def check
    render json: { message: 'up'}, status: :ok
  end
end
