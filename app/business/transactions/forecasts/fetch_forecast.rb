module Transactions
  module Forecasts
    class FetchForecast < ApplicationTransaction
      include Dry::Transaction(container: Containers::Forecasts::Container)

      step :validate_zipcode, with: "validate_zipcode"
      step :load_cached_forecast, with: "load_cached_forecast"
      step :resolve_geolocation, with: "resolve_geolocation"
      step :fetch_weather, with: "fetch_weather"
      step :persist_forecast_cache, with: "persist_forecast_cache"
      step :build_response, with: "build_response"
    end
  end
end

