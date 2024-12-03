# spec/controllers/integration_controller_spec.rb
require 'rails_helper'

RSpec.describe IntegrationController, type: :controller do
  describe 'POST #find_company' do
    let!(:company) { Company.create(name: 'Test Company', job_board: 'greenhouse') }

    context 'when the company exists in the database' do
      it 'returns a found status' do
        post :find_company, params: { company: 'Test Company' }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq({ 'status' => 'found' })
      end
    end

    context 'when the company does not exist in the database' do
      before do
        allow(controller).to receive(:fetch_from_greenhouse).and_return(false)
        allow(controller).to receive(:fetch_from_ashby).and_return(false)
        allow(controller).to receive(:fetch_from_lever).and_return(false)
      end

      it 'returns a not found status when no company is found' do
        post :find_company, params: { company: 'Nonexistent Company' }
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)).to eq({ 'status' => 'not found' })
      end

      it 'returns a found status when the company is found via Greenhouse' do
        allow(controller).to receive(:fetch_from_greenhouse).and_return(true)

        post :find_company, params: { company: 'Nonexistent Company' }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq({ 'status' => 'found' })
      end

      it 'returns a found status when the company is found via Ashby' do
        allow(controller).to receive(:fetch_from_ashby).and_return(true)

        post :find_company, params: { company: 'Nonexistent Company' }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq({ 'status' => 'found' })
      end

      it 'returns a found status when the company is found via Lever' do
        allow(controller).to receive(:fetch_from_lever).and_return(true)

        post :find_company, params: { company: 'Nonexistent Company' }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq({ 'status' => 'found' })
      end
    end
  end
end