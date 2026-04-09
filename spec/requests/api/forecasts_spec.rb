require 'rails_helper'

RSpec.describe 'Api::Forecasts', type: :request do
  let(:token) { ENV.fetch('INTERNAL_API_AUTH_TOKEN', 'development-token') }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  before do
    Rails.cache.clear
  end

  describe 'GET /api/forecast' do
    it 'returns the forecast payload and persists a new geolocation' do
      zipcode = '60601'
      stub_geolocation_request(zipcode:, latitude: '40.7357', longitude: '-74.1724')
      stub_weather_request(latitude: '40.7357', longitude: '-74.1724')

      get '/api/forecast', params: { zipcode: zipcode }, headers: headers

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
      expect(Geolocation.find_by(zipcode: zipcode)).to have_attributes(
        latitude: BigDecimal('40.7357'),
        longitude: BigDecimal('-74.1724')
      )
    end

    it 'returns a cached result on subsequent calls' do
      geolocation = create(:geolocation, zipcode: fake_postal_code, latitude: 40.7357, longitude: -74.1724)
      weather_request = stub_weather_request(latitude: '40.7357', longitude: '-74.1724')

      get '/api/forecast', params: { zipcode: geolocation.zipcode }, headers: headers
      get '/api/forecast', params: { zipcode: geolocation.zipcode }, headers: headers

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.dig('data', 'cachedResult')).to be(true)
      expect(weather_request).to have_been_requested.once
    end

    it 'returns unauthorized without a bearer token' do
      get '/api/forecast', params: { zipcode: fake_postal_code }

      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body).to eq(
        'data' => { 'error' => 'Unauthorized' }
      )
    end

    it 'returns validation errors for an invalid zipcode' do
      get '/api/forecast', params: { zipcode: '!!' }, headers: headers

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body).to eq(
        'data' => {
          'error' => 'Invalid params',
          'details' => { 'zipcode' => ['must be a valid postal code'] }
        }
      )
    end
  end

  def stub_geolocation_request(zipcode:, latitude:, longitude:)
    stub_request(:get, "https://nominatim.openstreetmap.org/search?country=Brazil&format=json&postalcode=#{zipcode}")
      .to_return(
        status: 200,
        body: [{
          'lat' => latitude,
          'lon' => longitude,
          'display_name' => '03407-000, St. ABC'
        }].to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  def stub_weather_request(latitude:, longitude:)
    stub_request(:get, %r{api\.open-meteo\.com/v1/forecast})
      .with do |request|
        request.uri.query_values['latitude'] == latitude &&
          request.uri.query_values['longitude'] == longitude
      end
      .to_return(
        status: 200,
        body: {
          'current' => { 'temperature_2m' => 25.0, 'relative_humidity_2m' => 38, 'rain' => 0.00 },
          'current_units' => { 'temperature_2m' => '°C' },
          'daily' => {
            'temperature_2m_min' => [20.0],
            'temperature_2m_max' => [28.0]
          }
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end
end
