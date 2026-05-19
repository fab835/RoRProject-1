require 'rails_helper'

RSpec.describe Containers::Forecasts::PersistForecastCache do
  include Dry::Monads[:result]

  subject(:operation) { described_class.resolve('persist_forecast_cache') }

  let(:file_cache) { ActiveSupport::Cache.lookup_store(:file_store, file_caching_path) }
  let(:temperature) { Entities::TemperatureEntity.new(min: 20.0, max: 28.0, current: 25.0, unit: 'celsius') }
  let(:extra) { Entities::ExtraEntity.new(humidity: 38, rain: 0.0) }

  before do
    allow(Rails).to receive(:cache).and_return(file_cache)
    described_class.instance_variable_set(:@cache, file_cache)
    file_cache.clear
  end

  it 'persists the forecast payload in cache and returns the response payload' do
    result = operation.call(zipcode: '60601', cached_payload: nil, temperature:, extra:)

    expect(result).to be_success
    expect(result.value!.fetch(:response_payload)).to eq(
      zipcode: '60601',
      cached_result: false,
      forecast: {
        temperature: temperature.as_json,
        extra: extra.as_json
      }
    )
    expect(file_cache.read('forecast:60601')).to eq(
      zipcode: '60601',
      forecast: {
        temperature: temperature.as_json,
        extra: extra.as_json
      }
    )
  end

  it 'skips writing when the result is already cached' do
    input = { zipcode: '60601', cached_payload: { zipcode: '60601' } }

    result = operation.call(input)

    expect(result).to be_success
    expect(result.value!).to eq(input)
    expect(file_cache.read('forecast:60601')).to be_nil
  end
end
