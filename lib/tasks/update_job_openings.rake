require 'net/http'
require 'json'

namespace :openings do
  desc "Fetch job openings from multiple platforms and save them to the Openings model"
  task update_job_openings: :environment do
    companies = [
      "nextrollinc", "Karius", "Harness", "Discord", "Whatnot", "vesta", "gluegroups",
      "Smartsheet", "centivo", "blackmere", "prometheum", "Redcar", "Carta", "Everlaw",
      "coder", "Imply", "Underground Administration", "notion", "Zip", "Figma", "BetterUp",
      "profluent", "Gridware", "kikoff", "luminary", "flocksafety", "mindsdb", "Rhombus",
      "Avathon", "volleythat", "Maximus", "Check", "Parabola", "alchemy", "kira-learning",
      "joinhandshake", "goodleap", "comfortclick", "EngagedMD", "sentilink", "Paypal",
      "instead", "anon", "candidhealth", "pavilion", "walmart", "valohealth",
      "seam", "databento", "persona", "miter", "HeyGen", "billcom", "atomicsemi", "everlaw",
      "Commure-Athelas", "Kargo", "Study.com", "Joyous", "GAPINC", "perplexityai",
      "DriveTime", "meroxa", "Figure", "Neural", "gynger", "Intrinsic", "Waymo", "Lyft",
      "harvey", "demandbase", "mikmak", "abodo", "Replicate", "pushpress", 
      "City of San Leandro", "arcade", "clearstory", "strava", "Gifthealth", "Opal",
      "middesk", "mindsdb", "surreal", "tabapay", "vercel", "flumehealth", "nudge", 
      "iPacket", "divergehealth"
    ]

    companies.each do |company_name|
      create_company_and_openings(company_name)
    end
  end

  def create_company_and_openings(company_name)
    # Create or find the company
    company = Company.find_or_create_by(name: company_name) do |c|
      c.job_board = 'unknown'  # Set a default job board or any other attributes
      c.working = false
      c.last_ran = Time.now
    end

    # Check Ashby
    ashby_url = URI("https://api.ashbyhq.com/posting-api/job-board/#{company_name.parameterize}?includeCompensation=true")
    ashby_response = Net::HTTP.get_response(ashby_url)

    if ashby_response.is_a?(Net::HTTPSuccess)
      data = JSON.parse(ashby_response.body)
      puts "Ashby: Found openings for #{company_name}"

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
      puts "Ashby: No openings found for #{company_name} or failed to fetch."
    end

    # Check Lever
    lever_url = URI("https://api.lever.co/v0/postings/#{company_name.parameterize}")
    lever_response = Net::HTTP.get_response(lever_url)

    if lever_response.is_a?(Net::HTTPSuccess)
      data = JSON.parse(lever_response.body)
      puts "Lever: Found openings for #{company_name}"

      # Delete existing openings for the company before creating new ones
      Opening.where(company: company.name).destroy_all
      puts "Deleted existing openings for #{company.name}"

      if data.is_a?(Array)
        data.each do |job|
          begin
            timestamp_seconds = job['createdAt'] / 1000.0 # Convert to seconds
            posted_on_date = Time.at(timestamp_seconds)
            Opening.create!(
              job_url: job['applyUrl'],
              location: job['categories']['location'] || 'Remote',
              title: job['text'],
              company: company.name,
              posted_on: posted_on_date
            )
            puts "Created opening for #{job['text']} at #{company.name}"
          rescue ActiveRecord::RecordInvalid => e
            puts "Failed to create opening for #{company.name}: #{e.message}"
          end
        end
      else
        puts "Lever: No postings found for #{company_name}."
      end
    else
      puts "Lever: No openings found for #{company_name} or failed to fetch."
    end

    # Check Greenhouse
    greenhouse_url = URI("https://boards-api.greenhouse.io/v1/boards/#{company_name.parameterize}/jobs")
    greenhouse_response = Net::HTTP.get_response(greenhouse_url)

    if greenhouse_response.is_a?(Net::HTTPSuccess)
      data = JSON.parse(greenhouse_response.body)
      puts "Greenhouse: Found openings for #{company_name}"

      # Delete existing openings for the company before creating new ones
      Opening.where(company: company.name).destroy_all
      puts "Deleted existing openings for #{company.name}"

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
      puts "Greenhouse: No openings found for #{company_name} or failed to fetch."
    end
  end
end