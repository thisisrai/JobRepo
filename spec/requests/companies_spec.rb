require 'rails_helper'

RSpec.describe "Companies", type: :request do
  # Create an admin user with an authorized email
  let(:admin_user) { create(:user, username: 'thisisrailee@gmail.com', password: 'password123') }
  
  let(:valid_attributes) do
    {
      company: {
        name: "Test Company",
        working: true,
        job_board: "LinkedIn",
        last_ran: Date.current
      }
    }
  end

  let(:invalid_attributes) do
    {
      company: {
        name: nil
      }
    }
  end

  before do
    # Mock the current_user method to return the admin_user
    allow_any_instance_of(CompaniesController).to receive(:current_user).and_return(admin_user)
  end

  describe "GET /companies" do
    it "returns a successful response" do
      create(:company, name: "Company A")
      create(:company, name: "Company B")

      get companies_path
      expect(response).to have_http_status(:ok)

      companies = JSON.parse(response.body)
      expect(companies.length).to eq(2)
      expect(companies.map { |c| c["name"] }).to include("Company A", "Company B")
    end
  end

  describe "GET /companies/:id" do
    it "returns the requested company" do
      company = create(:company)

      get company_path(company)
      expect(response).to have_http_status(:ok)

      company_response = JSON.parse(response.body)
      expect(company_response["name"]).to eq(company.name)
    end

    it "returns not found for invalid ID" do
      get company_path(id: 999999)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /companies" do
    context "with valid parameters" do
      it "creates a new company" do
        expect {
          post companies_path, params: valid_attributes
        }.to change(Company, :count).by(1)

        expect(response).to have_http_status(:created)
        created_company = JSON.parse(response.body)
        expect(created_company["name"]).to eq("Test Company")
      end
    end

    context "with invalid parameters" do
      it "does not create a new company" do
        expect {
          post companies_path, params: invalid_attributes
        }.not_to change(Company, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["errors"]).to include("Name can't be blank")
      end
    end
  end

  describe "PATCH /companies/:id" do
    let!(:company) { create(:company) }

    context "with valid parameters" do
      it "updates the requested company" do
        patch company_path(company), params: { company: { name: "Updated Company" } }
        expect(response).to have_http_status(:ok)

        company.reload
        expect(company.name).to eq("Updated Company")
      end
    end

    context "with invalid parameters" do
      it "does not update the company" do
        patch company_path(company), params: invalid_attributes
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["errors"]).to include("Name can't be blank")
      end
    end
  end

  describe "DELETE /companies/:id" do
    let!(:company) { create(:company) }

    it "deletes the requested company" do
      expect {
        delete company_path(company)
      }.to change(Company, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end