require 'net/http'
require 'json'

namespace :openings do
  desc "Fetch job openings for 10 companies with the oldest last_ran and save them to the Openings model"
  task update_lever: :environment do
    # Find 10 companies with job_board 'lever' and the oldest last_ran
    companies = Company.where(job_board: 'lever').order(:last_ran).limit(10)

    companies.each do |company|
      sleep 1
      company_name = company.name.parameterize # e.g., 'Example Company' -> 'example-company'
      url = URI("https://api.lever.co/v0/postings/#{company_name}")

      response = Net::HTTP.get_response(url)

      if response.is_a?(Net::HTTPSuccess)
        data = JSON.parse(response.body)

        # Debugging: Print the entire response data
        puts "Response data for #{company.name}: #{data.inspect}"

        # Update company attributes if API call is successful
        company.update(working: true, last_ran: Time.now)
        puts "Updated #{company.name} with working: true and job_board: 'lever'"

        # Delete existing openings for the company before creating new ones
        Opening.where(company: company.name).destroy_all
        puts "Deleted existing openings for #{company.name}"

        # Check if 'postings' key exists and is an array
        if data.is_a?(Array)
          data.each do |job| # Access the 'postings' key
            begin
              timestamp_seconds = job['createdAt'] / 1000.0 # Convert to seconds
              posted_on_date = Time.at(timestamp_seconds)
              Opening.create!(
                job_url: job['applyUrl'],
                location: job['categories']['location'] || 'Remote', # Default to 'Remote' if location is not provided
                title: job['text'],
                company: company.name,
                posted_on: posted_on_date
              )
              puts "Created opening for #{job['text']} at #{company.name}" # Changed 'title' to 'text' for consistency
            rescue ActiveRecord::RecordInvalid => e
              puts "Failed to create opening for #{company.name}: #{e.message}"
            end
          end
        else
          puts "No postings found for #{company.name} or 'postings' is not an array."
        end
      else
        puts "Failed to fetch jobs for #{company.name}. HTTP Status: #{response.code}"
      end
    end
  end
end