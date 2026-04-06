module Containers
  module Forecasts 
    class LoadCachedForecast < ApplicationContainer
      @cache = Rails.cache
      
      register 'load_cached_forecast' do |input|
        cached_payload = @cache.read("forecast:#{input.fetch(:zipcode)}")

        Dry::Monads::Success(input.merge(cached_payload:))
      rescue StandardError => exception
        Dry::Monads::Failure(type: :internal_error, message: exception.message)
      end
    end
  end
end
