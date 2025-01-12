require 'rake'
require 'csv'
require 'net/http'
require 'json'

namespace :integration do
  desc "Integrate companies from CSV"
  task process_companies: :environment do

    file_path = Rails.root.join('companies.csv')
    companies = CSV.read(file_path, headers: true)

    companies.each do |row|
      company_param = row['Company Name'].to_s.strip.gsub(/\s+/, '') # Trim and remove spaces
      puts "Processing company: #{company_param}"

      company = Company.find_by("LOWER(name) = ?", company_param.downcase)

      if company
        company.destroy 

        company = Company.find_by("LOWER(name) = ?", company_param.downcase)
      end

      if company
        if company.working
          puts "Company found: #{company.name}, Status: working"
        else
          puts "Company found: #{company.name}, Status: not working"
        end
      else
        found = fetch_from_greenhouse(company_param) ||
                fetch_from_ashby(company_param) ||
                fetch_from_lever(company_param)

        if found
          puts "Company #{company_param} found and created."
        else
          Company.create(name: company_param, job_board: 'unknown', working: false)
          puts "Company #{company_param} not found, created as not working."
        end
      end
    end
  end

  private

  def self.fetch_from_greenhouse(company_param)
    url = URI("https://boards-api.greenhouse.io/v1/boards/#{company_param}/jobs")
    response = Net::HTTP.get_response(url)

    if response.is_a?(Net::HTTPSuccess)
      data = JSON.parse(response.body)
      if data['jobs'].any?
        Company.create(name: company_param, job_board: 'greenhouse', working: true)
        return true
      end
    end
    false
  end

  def self.fetch_from_ashby(company_param)
    url = URI("https://api.ashbyhq.com/posting-api/job-board/#{company_param}?includeCompensation=true")
    response = Net::HTTP.get_response(url)

    if response.is_a?(Net::HTTPSuccess)
      data = JSON.parse(response.body)
      if data['jobs'].any?
        Company.create(name: company_param, job_board: 'ashby', working: true)
        return true
      end
    end
    false
  end

  def self.fetch_from_lever(company_param)
    url = URI("https://api.lever.co/v0/postings/#{company_param}")
    response = Net::HTTP.get_response(url)

    if response.is_a?(Net::HTTPSuccess)
      data = JSON.parse(response.body)
      if data.any?
        Company.create(name: company_param, job_board: 'lever', working: true)
        return true
      end
    end
    false
  end
end