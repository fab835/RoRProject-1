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
          raise StandardError, response.failure if response.failure?

          temperature = Entities::TemperatureEntity.new(
            min: response.value![:min],
            max: response.value![:max],
            current: response.value![:current],
            unit: response.value![:unit]
          )

          Dry::Monads::Success(input.merge(temperature:))
        end
      rescue StandardError => exception
        Dry::Monads::Failure(type: :internal_error, message: exception.message)
      end
    end
  end
end
