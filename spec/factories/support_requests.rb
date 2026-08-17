FactoryBot.define do
  factory :support_request do
    user
    subject { Faker::Lorem.sentence(word_count: 5) }
    message { Faker::Lorem.paragraph(sentence_count: 5) }
    status { "open" }

    trait :open do
      status { "open" }
    end

    trait :in_progress do
      status { "in_progress" }
    end

    trait :resolved do
      status { "resolved" }
    end

    trait :closed do
      status { "closed" }
    end
  end
end
