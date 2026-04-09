FactoryBot.define do
  factory :temperature_entity, class: 'Entities::TemperatureEntity' do
    min { Faker::Number.positive.positive(from: 1.00, to: 20.00) }
    min { Faker::Number.positive.positive(from: 20.00, to: 40.00) }
    current { Faker::Number.positive.positive(from: 1.00, to: 20.00) }
    unit { 'celsius' }

    initialize_with { new(attributes.with_indifferent_access) }
  end
end
