require 'net/http'
require 'json'

namespace :openings do
  desc "Fetch job openings for 10 companies with the oldest last_ran from Ashby and save them to the Openings model"
  task update_ashby: :environment do
    # Find 10 companies with job_board 'ashby' and the oldest last_ran
    companies = Company.where(job_board: 'ashby').order(:last_ran).limit(10)

    companies.each do |company|
      sleep 1
      company_name = company.name.parameterize
      url = URI("https://api.ashbyhq.com/posting-api/job-board/#{company_name}?includeCompensation=true")

      response = Net::HTTP.get_response(url)

      if response.is_a?(Net::HTTPSuccess)
        data = JSON.parse(response.body)

        # Update company attributes if API call is successful
        company.update(working: true, last_ran: Time.now)
        puts "Updated #{company.name} with working: true and job_board: 'ashby'"

        # Delete existing openings for the company before creating new ones
        Opening.where(company: company.name).destroy_all
        puts "Deleted existing openings for #{company.name}"

        data['jobs']&.each do |job|
          begin
            posted_on_date = Date.parse(job['publishedAt']) rescue nil
            Opening.create!(
              job_url: job['jobUrl'],
              location: job['address']&.dig('postalAddress', 'addressLocality') || job['location'],
              title: job['title'],
              company: company.name,
              posted_on: posted_on_date
            )
            puts "Created opening for #{job['title']} at #{company.name}"
          rescue ActiveRecord::RecordInvalid => e
            puts "Failed to create opening for #{company.name}: #{e.message}"
          end
        end
      else
        puts "Failed to fetch jobs for #{company.name}. HTTP Status: #{response.code}"
      end
    end
  end
end
