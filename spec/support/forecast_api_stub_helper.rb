module ForecastApiStubHelper
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

  def stub_geolocation_request_failed(zipcode:)
    stub_request(:get, "https://nominatim.openstreetmap.org/search?country=Brazil&format=json&postalcode=#{zipcode}")
      .to_return(
        status: 200,
        body: [].to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  def stub_geolocation_secondary_request(zipcode:, latitude:, longitude:, country: 'us')
    stub_request(:get, "https://api.zippopotam.us/#{country}/#{zipcode}")
      .to_return(
        status: 200,
        body: {
          "country": "United States",
          "country abbreviation": "US",
          "post code": zipcode.to_s,
          "places": [
            {
              "place name": "Chicago",
              "longitude": longitude.to_s,
              "latitude": latitude.to_s,
              "state": "Illinois",
              "state abbreviation": "IL"
            }
          ]
        }.to_json,
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

RSpec.configure do |config|
  config.include ForecastApiStubHelper
end
