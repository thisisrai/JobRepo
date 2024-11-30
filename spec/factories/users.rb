FactoryBot.define do
  factory :user do
    username { "regular@example.com" }
    password { "123" }
    password_digest { BCrypt::Password.create("123") }

    trait :admin do
      username { "admin@gmail.com" }
    end

    trait :admin2 do
      username { "admin@coffeejob.io" }
    end
  end
end