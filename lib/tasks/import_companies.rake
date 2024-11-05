require 'csv'

namespace :import do
  desc "Import companies from zxy.csv"
  task companies: :environment do
    file_path = Rails.root.join('zxy.csv')
    
    unless File.exist?(file_path)
      puts "File not found: #{file_path}"
      next
    end

    Company.delete_all
    
    CSV.foreach(file_path, headers: true) do |row|
      company_name = row['Company'].strip.gsub(" ", "")

      application_url = row['Application URL']

      if application_url =~ /greenhouse|lever|ashbyhq/i
        company = Company.find_or_initialize_by(name: company_name)
        if company.save
          puts "Created/updated company: #{company_name} with URL: #{application_url}"
        else
          puts "Failed to save company: #{company_name}. Errors: #{company.errors.full_messages.join(", ")}"
        end
      else
        puts "Skipped #{company_name}: URL does not contain specified keywords"
      end
    end
    
    puts "Company import completed."
  end
end
