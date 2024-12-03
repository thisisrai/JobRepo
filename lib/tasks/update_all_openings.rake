namespace :openings do
  desc "Fetch job openings from both Ashby and Greenhouse"
  task update_all: [:environment] do
    puts "Fetching job openings from Ashby..."
    Rake::Task["openings:update_ashby"].invoke

    puts "Fetching job openings from Greenhouse..."
    Rake::Task["openings:update_greenhouse"].invoke

    puts "Fetching job openings from Lever..."
    Rake::Task["openings:update_lever"].invoke

    puts "Completed fetching job openings from both sources."
  end
end