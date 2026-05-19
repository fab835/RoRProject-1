require 'rails_helper'

RSpec.describe Containers::Forecasts::BuildResponse do
  include Dry::Monads[:result]

  subject(:operation) { described_class.resolve('build_response') }

  let(:payload) do
    {
      zipcode: '60601',
      cached_result: false,
      forecast: {
        temperature: { min: 20.0, max: 28.0, current: 25.0, unit: 'celsius' },
        extra: { humidity: 38, rain: 0.0 }
      }
    }
  end

  it 'builds a forecast entity from a fresh response payload' do
    result = operation.call(response_payload: payload, cached_payload: nil)

    expect(result).to be_success
    expect(result.value!).to be_a(Entities::ForecastEntity)
    expect(result.value!.as_json).to eq(
      zipcode: '60601',
      cachedResult: false,
      forecast: payload[:forecast]
    )
  end

  it 'marks cached payloads as cached results in the response entity' do
    cached_payload = payload.except(:cached_result)

    result = operation.call(cached_payload:)

    expect(result).to be_success
    expect(result.value!.as_json).to eq(
      zipcode: '60601',
      cachedResult: true,
      forecast: payload[:forecast]
    )
  end
end
