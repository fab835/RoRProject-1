require 'rails_helper'

RSpec.describe GeolocationApi::ClientSecondary do
  describe '#fetch' do
    it 'returns coordinates from the secondary geolocation API' do
      zipcode = '60601'

      stub_request(:get, "https://api.zippopotam.us/us/#{ERB::Util.url_encode(zipcode)}")
        .to_return(
          status: 200,
          body: {
            'places' => [
              {
                'place name': 'Holtsville',
                'latitude' => '51.5010',
                'longitude' => '-0.1416',
                'state' => 'New York',
                'state abbreviation' => 'NY'
              }
            ]
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      result = described_class.new.fetch(zipcode: zipcode)

      expect(result).to eq(latitude: 51.501, longitude: -0.1416, display_name: 'Holtsville NY')
    end

    it 'raises a not found error when the postal code does not exist' do
      zipcode = '60601'

      stub_request(:get, "https://api.zippopotam.us/us/#{ERB::Util.url_encode(zipcode)}")
        .to_return(status: 404, body: {}.to_json, headers: { 'Content-Type' => 'application/json' })

      expect { described_class.new.fetch(zipcode: zipcode) }
        .to raise_error(DefaultError) { |error| expect(error.type).to eq(:not_found) }
    end
  end
end
