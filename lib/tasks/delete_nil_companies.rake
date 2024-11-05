namespace :companies do
  desc "Delete all companies without a job_board value"
  task delete_without_job_board: :environment do
    companies_without_job_board = Company.where(job_board: [nil, ''])
    count = companies_without_job_board.count

    if count > 0
      companies_without_job_board.destroy_all
      puts "Deleted #{count} companies without a job_board value."
    else
      puts "No companies found without a job_board value."
    end
  end
end
