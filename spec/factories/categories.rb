FactoryBot.define do
  factory :category do
    name { Faker::Commerce.unique.department }
    slug { name.downcase.gsub(' ', '-') }
  end
end
