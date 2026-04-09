require 'rails_helper'

RSpec.describe Transactions::Forecasts::FetchForecast do
  include Dry::Monads[:result]

  subject(:transaction) { described_class.new }

  let(:geolocation) { Geolocation.new(zipcode: '03456', latitude: 40.7357, longitude: -74.1724) }
  let(:temperature) { Entities::TemperatureEntity.new(min: 20.0, max: 28.0, current: 25.0, unit: 'celsius') }
  let(:extra) { Entities::ExtraEntity.new(humidity: 30, rain: 0.0) }
  let(:validate_zipcode) { instance_double(Proc) }
  let(:load_cached_forecast) { instance_double(Proc) }
  let(:resolve_geolocation) { instance_double(Proc) }
  let(:fetch_weather) { instance_double(Proc) }
  let(:persist_forecast_cache) { instance_double(Proc) }
  let(:build_response) { instance_double(Proc) }

  before do
    stub_container_step('validate_zipcode', validate_zipcode)
    stub_container_step('load_cached_forecast', load_cached_forecast)
    stub_container_step('resolve_geolocation', resolve_geolocation)
    stub_container_step('fetch_weather', fetch_weather)
    stub_container_step('persist_forecast_cache', persist_forecast_cache)
    stub_container_step('build_response', build_response)
  end

  it 'orchestrates the transaction steps and formats the payload' do
    validated_input = { zipcode: '03456' }
    cached_input = { zipcode: '03456', cached_payload: nil }
    geolocation_input = cached_input.merge(geolocation:)
    weather_input = geolocation_input.merge(temperature:)
    response_payload = {
      zipcode: '03456',
      cached_result: false,
      forecast: { temperature: temperature.as_json, extra: extra.as_json }
    }
    response_input = weather_input.merge(response_payload:)
    forecast_entity = Entities::ForecastEntity.new(response_payload)

    allow(validate_zipcode).to receive(:call).with(zipcode: '03456').and_return(Success(validated_input))
    allow(load_cached_forecast).to receive(:call).with(validated_input).and_return(Success(cached_input))
    allow(resolve_geolocation).to receive(:call).with(cached_input).and_return(Success(geolocation_input))
    allow(fetch_weather).to receive(:call).with(geolocation_input).and_return(Success(weather_input))
    allow(persist_forecast_cache).to receive(:call).with(weather_input).and_return(Success(response_input))
    allow(build_response).to receive(:call).with(response_input).and_return(Success(forecast_entity))

    result = transaction.call(zipcode: '03456')

    expect(result).to be_success
    expect(result.value!).to eq(forecast_entity)
  end

  it 'returns cached results through the transaction' do
    validated_input = { zipcode: '03456' }
    cached_input = {
      zipcode: '03456',
      cached_payload: {
        zipcode: '03456',
        forecast: { temperature: temperature.as_json, extra: extra.as_json }
      }
    }
    forecast_entity = Entities::ForecastEntity.new(
      zipcode: '03456',
      cached_result: true,
      forecast: { temperature: temperature.as_json, extra: extra.as_json }
    )

    allow(validate_zipcode).to receive(:call).with(zipcode: '03456').and_return(Success(validated_input))
    allow(load_cached_forecast).to receive(:call).with(validated_input).and_return(Success(cached_input))
    allow(resolve_geolocation).to receive(:call).with(cached_input).and_return(Success(cached_input))
    allow(fetch_weather).to receive(:call).with(cached_input).and_return(Success(cached_input))
    allow(persist_forecast_cache).to receive(:call).with(cached_input).and_return(Success(cached_input))
    allow(build_response).to receive(:call).with(cached_input).and_return(Success(forecast_entity))

    result = transaction.call(zipcode: '03456')

    expect(result).to be_success
    expect(result.value!.cached_result).to be(true)
  end

  def stub_container_step(key, operation)
    allow(Containers::Forecasts::Container).to receive(:[]).with(key).and_return(operation)
  end
end
