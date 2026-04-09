module Containers
  module Forecasts
    class FetchWeather < ApplicationContainer
      @client = WeatherApi::Client.new

      register 'fetch_weather' do |input|
        if input[:cached_payload].present?
          Dry::Monads::Success(input)
        else
          geolocation = input.fetch(:geolocation)
          response = @client.fetch(latitude: geolocation.latitude.to_f, longitude: geolocation.longitude.to_f)

          temperature = Entities::TemperatureEntity.new(
            min: response[:min],
            max: response[:max],
            current: response[:current],
            unit: response[:unit]
          )

          extra = Entities::ExtraEntity.new(
            humidity: response[:humidity] || 0,
            rain: response[:rain] || 0
          )

          Dry::Monads::Success(input.merge({ temperature:, extra: }))
        end
      rescue DefaultError => exception
        Dry::Monads::Failure(type: exception.type, message: exception.errors)
      rescue StandardError => exception
        Dry::Monads::Failure(type: :internal_error, message: exception.message)
      end
    end
  end
end
