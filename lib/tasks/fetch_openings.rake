require 'net/http'
require 'json'

namespace :openings do
  desc "Fetch job openings for each company and save them to the Openings model"
  task fetch_from_greenhouse: :environment do
    Company.find_each do |company|
      sleep 1
      company_name = company.name.parameterize # e.g., 'Checkr' -> 'checkr'
      url = URI("https://boards-api.greenhouse.io/v1/boards/#{company_name}/jobs")

      response = Net::HTTP.get_response(url)

      if response.is_a?(Net::HTTPSuccess)
        data = JSON.parse(response.body)

        company.update(working: true, job_board: "greenhouse", last_ran: Time.now)
        puts "Updated #{company.name} with working: true and job_board: 'greenhouse'"

        data['jobs']&.each do |job|
          begin
            posted_on_date = Date.parse(job['updated_at']) rescue nil
            Opening.create!(
              job_url: job['absolute_url'],
              location: job['location']&.dig('name'),
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
