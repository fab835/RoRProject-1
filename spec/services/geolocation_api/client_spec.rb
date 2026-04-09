require 'rails_helper'

RSpec.describe GeolocationApi::Client do
  describe '#fetch' do
    it 'returns coordinates from the geolocation API' do
      zipcode = '03407-000'

      stub_request(:get, "https://nominatim.openstreetmap.org/search?country=Brazil&format=json&postalcode=#{zipcode}")
        .to_return(
          status: 200,
          body: [{
            'lat' => '-23.5440051',
            'lon' => '-46.5493018',
            'display_name' => '03407-000, St. ABC'
          }].to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      result = described_class.new.fetch(zipcode:)

      expect(result).to eq(latitude: -23.5440051, longitude: -46.5493018, display_name: '03407-000, St. ABC')
    end

    it 'raises a not found error when the postal code does not exist' do
      zipcode = '03407-000'

      stub_request(:get, "https://nominatim.openstreetmap.org/search?country=Brazil&format=json&postalcode=#{zipcode}")
        .to_return(status: 404, body: {}.to_json, headers: { 'Content-Type' => 'application/json' })

      expect { described_class.new.fetch(zipcode: zipcode) }
        .to raise_error(DefaultError) { |error| expect(error.type).to eq(:not_found) }
    end
  end
end
