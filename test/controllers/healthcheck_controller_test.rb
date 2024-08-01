require 'rails_helper'

RSpec.describe HealthcheckController, type: :controller do
  describe "GET #check" do
    it "returns a success response" do
      get :check
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq({ "message" => "up" })
    end
  end
end
