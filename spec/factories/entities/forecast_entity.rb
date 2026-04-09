FactoryBot.define do
  factory :forecast_entity, class: 'Entities::ForecastEntity' do
    sequence(:zipcode) { |n| "PC-#{n}#{Faker::Alphanumeric.alphanumeric(number: 4).upcase}" }
    cached_result { Faker::Boolean.boolean }
    forecast { OpenStruct.new(temperature: association(:temperature_entity)) }

    initialize_with { new(attributes.with_indifferent_access) }
  end
end
