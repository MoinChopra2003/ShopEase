FactoryBot.define do
  factory :support_article do
    title { Faker::Lorem.sentence(word_count: 5) }
    content { Faker::Lorem.paragraph(sentence_count: 10) }
    position { Faker::Number.between(from: 1, to: 100) }
    active { true }

    trait :inactive do
      active { false }
    end
  end
end
