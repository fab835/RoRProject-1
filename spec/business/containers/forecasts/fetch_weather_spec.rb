require 'rails_helper'

RSpec.describe Containers::Forecasts::FetchWeather do
  include Dry::Monads[:result]

  subject(:operation) { described_class.resolve('fetch_weather') }

  let(:geolocation) { Geolocation.new(zipcode: '60601', latitude: 40.7357, longitude: -74.1724) }

  it 'returns the input unchanged when a cached payload is already present' do
    weather_request = stub_weather_request(latitude: '40.7357', longitude: '-74.1724')
    input = { zipcode: '60601', cached_payload: { zipcode: '60601' } }

    result = operation.call(input)

    expect(result).to be_success
    expect(result.value!).to eq(input)
    expect(weather_request).not_to have_been_requested
  end

  it 'fetches and normalizes weather data for the geolocation' do
    weather_request = stub_weather_request(latitude: '40.7357', longitude: '-74.1724')
    result = operation.call(zipcode: '60601', cached_payload: nil, geolocation:)

    expect(result).to be_success
    expect(result.value!).to include(zipcode: '60601', cached_payload: nil, geolocation:)
    expect(result.value!.fetch(:temperature)).to have_attributes(min: 20.0, max: 28.0, current: 25.0, unit: 'celsius')
    expect(result.value!.fetch(:extra)).to have_attributes(humidity: 38, rain: 0.0)
    expect(weather_request).to have_been_requested.once
  end
end
