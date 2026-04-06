module Containers
  module Forecasts
    class PersistForecastCache < ApplicationContainer
      CACHE_TTL = 30.minutes
      @cache = Rails.cache

      register 'persist_forecast_cache' do |input|
        if input[:cached_payload].present?
          Dry::Monads::Success(input)
        else
          payload = {
            zipcode: input.fetch(:zipcode),
            cached_result: false,
            forecast: {
              temperature: input.fetch(:temperature).as_json
            }
          }

          @cache.write("forecast:#{input.fetch(:zipcode)}", payload.except(:cached_result), expires_in: CACHE_TTL)

          Dry::Monads::Success(input.merge(response_payload: payload))
        end
      rescue StandardError => exception
        Dry::Monads::Failure(type: :internal_error, message: exception.message)
      end
    end
  end
end
