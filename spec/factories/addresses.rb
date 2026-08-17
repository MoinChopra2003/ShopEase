FactoryBot.define do
  factory :address do
    user
    label { Faker::Address.unique.street_name }
    recipient_name { Faker::Name.name }
    phone_number { Faker::PhoneNumber.cell_phone.gsub(/[^0-9+]/, '').slice(0, 15) }
    address { Faker::Address.street_address }
    city { Faker::Address.city }
    country { Faker::Address.country }
    postal_code { Faker::Address.postcode.slice(0, 10) }
    default { false }

    trait :default do
      default { true }
    end
  end
end
