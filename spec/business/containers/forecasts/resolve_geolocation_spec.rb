require 'rails_helper'

RSpec.describe Containers::Forecasts::ResolveGeolocation do
  include Dry::Monads[:result]

  subject(:operation) { described_class.resolve('resolve_geolocation') }

  let(:zipcode) { '60601' }

  it 'returns an existing geolocation without calling the APIs' do
    geolocation = create(:geolocation, zipcode:, latitude: 40.7357, longitude: -74.1724) # Create geolocation in the db
    geolocation_request = stub_geolocation_request(zipcode:, latitude: '40.7357', longitude: '-74.1724')
    geolocation_request_secondary = stub_geolocation_secondary_request(
      zipcode:, latitude: '40.7357', longitude: '-74.1724'
    )

    result = operation.call(zipcode:, cached_payload: nil)

    expect(geolocation_request).not_to have_been_requested
    expect(geolocation_request_secondary).not_to have_been_requested
    expect(result).to be_success
    expect(result.value!).to eq(zipcode:, cached_payload: nil, geolocation:)
  end

  it 'creates a geolocation from the primary API when none exists' do
    geolocation_request = stub_geolocation_request(zipcode:, latitude: '40.7357', longitude: '-74.1724')
    geolocation_request_secondary = stub_geolocation_secondary_request(
      zipcode:, latitude: '40.7357', longitude: '-74.1724'
    )
    result = operation.call(zipcode:, cached_payload: nil)

    expect(geolocation_request).to have_been_requested.once
    expect(geolocation_request_secondary).not_to have_been_requested
    expect(result).to be_success
    expect(result.value!.fetch(:geolocation)).to have_attributes(
      zipcode:,
      latitude: BigDecimal('40.7357'),
      longitude: BigDecimal('-74.1724')
    )
    expect(Geolocation.find_by(zipcode:)).to be_present
  end

  it 'falls back to the secondary API when the primary one raises an error' do
    geolocation_request = stub_geolocation_request_failed(zipcode:)
    geolocation_request_secondary = stub_geolocation_secondary_request(
      zipcode:, latitude: '40.7357', longitude: '-74.1724'
    )
    result = operation.call(zipcode:, cached_payload: nil)

    # have been requested and failed, so we expect the secondary to be called
    expect(geolocation_request).to have_been_requested.once
    expect(geolocation_request_secondary).to have_been_requested.once
    expect(result).to be_success
    expect(result.value!.fetch(:geolocation)).to have_attributes(zipcode:)
  end
end
