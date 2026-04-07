require 'rails_helper'

RSpec.describe WeatherApi::Client do
  describe '#fetch' do
    it 'returns normalized weather data from the weather API' do
      stub_request(:get, %r{api\.open-meteo\.com/v1/forecast})
        .to_return(
          status: 200,
          body: {
            'current' => { 'temperature_2m' => 17.2 },
            'current_units' => { 'temperature_2m' => '°C' },
            'daily' => {
              'temperature_2m_min' => [12.5],
              'temperature_2m_max' => [21.3]
            }
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      result = described_class.new.fetch(latitude: 51.501, longitude: -0.1416)

      expect(result).to eq(min: 12.5, max: 21.3, current: 17.2, unit: 'celsius')
    end

    it 'raises an external api error for incomplete payloads' do
      stub_request(:get, %r{api\.open-meteo\.com/v1/forecast})
        .to_return(
          status: 200,
          body: {
            'current' => {},
            'current_units' => { 'temperature_2m' => '°C' },
            'daily' => {
              'temperature_2m_min' => [12.5],
              'temperature_2m_max' => [21.3]
            }
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      expect { described_class.new.fetch(latitude: 51.501, longitude: -0.1416) }
        .to raise_error(DefaultError) { |error| expect(error.type).to eq(:external_api_error) }
    end
  end
end
