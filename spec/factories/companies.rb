FactoryBot.define do
  factory :company do
    name { "Default Company Name" }
    working { true }
    job_board { "Default Job Board" }
    last_ran { Date.current }
  end
end
