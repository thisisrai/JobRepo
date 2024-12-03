class IntegrationController < ApplicationController
  require 'net/http'
  require 'json'

  def find_company
    # Get the company parameter from the request
    company_param = params[:company].to_s.strip.gsub(/\s+/, '') # Trim and remove spaces between characters

    # Look up the company in the database (case insensitive)
    company = Company.find_by("LOWER(name) = ?", company_param.downcase)

    if company
      render json: { status: 'found', company: company }, status: :ok
    else
      # If not found, make API requests to Greenhouse, Ashby, and Lever
      found = false

      found ||= fetch_from_greenhouse(company_param)
      found ||= fetch_from_ashby(company_param)
      found ||= fetch_from_lever(company_param)

      if found
        render json: { status: 'found' }, status: :ok
      else
        render json: { status: 'not found' }, status: :not_found
      end
    end
  end

  private

  def fetch_from_greenhouse(company_param)
    url = URI("https://boards-api.greenhouse.io/v1/boards/#{company_param}/jobs")
    response = Net::HTTP.get_response(url)

    if response.is_a?(Net::HTTPSuccess)
      data = JSON.parse(response.body)
      if data['jobs'].any?
        Company.create(name: company_param, job_board: 'greenhouse')
        return true
      end
    end
    false
  end

  def fetch_from_ashby(company_param)
    url = URI("https://api.ashbyhq.com/posting-api/job-board/#{company_param}?includeCompensation=true")
    response = Net::HTTP.get_response(url)

    if response.is_a?(Net::HTTPSuccess)
      data = JSON.parse(response.body)
      if data['jobs'].any?
        Company.create(name: company_param, job_board: 'ashby')
        return true
      end
    end
    false
  end

  def fetch_from_lever(company_param)
    url = URI("https://api.lever.co/v0/postings/#{company_param}")
    response = Net::HTTP.get_response(url)

    if response.is_a?(Net::HTTPSuccess)
      data = JSON.parse(response.body)
      if data.any?
        Company.create(name: company_param, job_board: 'lever')
        return true
      end
    end
    false
  end
end