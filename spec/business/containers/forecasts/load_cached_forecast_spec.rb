require 'rails_helper'

RSpec.describe Containers::Forecasts::LoadCachedForecast do
  include Dry::Monads[:result]

  subject(:operation) { described_class.resolve('load_cached_forecast') }

  let(:file_cache) { ActiveSupport::Cache.lookup_store(:file_store, file_caching_path) }

  before do
    allow(Rails).to receive(:cache).and_return(file_cache)
    described_class.instance_variable_set(:@cache, file_cache)
    file_cache.clear
  end

  it 'loads the cached payload into the input' do
    allow(file_cache).to receive(:read).and_call_original
    payload = { zipcode: '60601', forecast: { temperature: { current: 25.0 } } }
    file_cache.write('forecast:60601', payload)

    result = operation.call(zipcode: '60601')

    expect(result).to be_success
    expect(result.value!).to eq(zipcode: '60601', cached_payload: payload)
    expect(file_cache).to have_received(:read).with('forecast:60601').once
  end

  it 'returns nil when there is no cached payload' do
    result = operation.call(zipcode: '60601')

    expect(result).to be_success
    expect(result.value!).to eq(zipcode: '60601', cached_payload: nil)
    expect(file_cache.read('forecast:60601')).to be_nil
  end
end
