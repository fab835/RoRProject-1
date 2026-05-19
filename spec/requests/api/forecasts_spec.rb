require 'rails_helper'

RSpec.describe 'Api::Forecasts', type: :request do
  let(:token) { ENV.fetch('INTERNAL_API_AUTH_TOKEN', 'development-token') }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  before do
    Geolocation.delete_all
    Rails.cache.clear
  end

  describe 'GET /api/forecast' do
    it 'returns the forecast payload and persists a new geolocation' do
      zipcode = '60601'
      stub_geolocation_request(zipcode:, latitude: '40.7357', longitude: '-74.1724')
      stub_weather_request(latitude: '40.7357', longitude: '-74.1724')

      get("/api/forecast/#{zipcode}", headers:)

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq(
        'data' => {
          'zipcode' => zipcode,
          'cachedResult' => false,
          'forecast' => {
            'temperature' => {
              'min' => 20.0,
              'max' => 28.0,
              'current' => 25.0,
              'unit' => 'celsius'
            },
            'extra' => {
              'humidity' => 38,
              'rain' => 0.0
            }
          }
        }
      )
      expect(Geolocation.find_by(zipcode:)).to have_attributes(
        latitude: BigDecimal('40.7357'),
        longitude: BigDecimal('-74.1724')
      )
    end

    it 'returns a cached result on subsequent calls' do
      geolocation = create(:geolocation, zipcode: fake_postal_code, latitude: 40.7357, longitude: -74.1724)
      weather_request = stub_weather_request(latitude: '40.7357', longitude: '-74.1724')

      get("/api/forecast/#{geolocation.zipcode}", headers:)
      get("/api/forecast/#{geolocation.zipcode}", headers:)

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.dig('data', 'cachedResult')).to be(true)
      expect(weather_request).to have_been_requested.once
    end

    it 'returns unauthorized without a bearer token' do
      get "/api/forecast/#{fake_postal_code}"

      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body).to eq(
        'data' => { 'error' => 'Unauthorized' }
      )
    end

    it 'returns validation errors for an invalid zipcode' do
      get('/api/forecast/invalidzipcode', headers:)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body).to eq(
        'data' => {
          'error' => 'Invalid params',
          'details' => { 'zipcode' => ['must be a valid postal code'] }
        }
      )
    end
  end
end
