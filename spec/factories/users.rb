FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.unique.email }
    password { "TestPassword123!" }
    password_confirmation { "TestPassword123!" }
    status { "active" }

    trait :inactive do
      status { "inactive" }
    end

    trait :deleted do
      status { "deleted" }
    end
  end
end
