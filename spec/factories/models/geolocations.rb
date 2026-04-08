FactoryBot.define do
  factory :geolocation do
    sequence(:zipcode) { |n| "PC-#{n}#{Faker::Alphanumeric.alphanumeric(number: 4).upcase}" }
    latitude { Faker::Address.latitude }
    longitude { Faker::Address.longitude }
  end
end
