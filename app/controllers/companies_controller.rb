class CompaniesController < ApplicationController
  include Authenticatable

  before_action :authenticate_admin!
  before_action :set_company, only: [:show, :update, :destroy]

  def index
    companies = Company.all
    render json: companies
  end

  def show
    render json: @company
  end

  def create
    company = Company.new(company_params)

    if company.save
      render json: company, status: :created
    else
      render json: { errors: company.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @company.update(company_params)
      render json: @company
    else
      render json: { errors: @company.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @company.destroy
    head :no_content
  end

  private

  def set_company
    @company = Company.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Company not found' }, status: :not_found
  end

  def company_params
    params.require(:company).permit(:name, :working, :job_board, :last_ran)
  end
end
