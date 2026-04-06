module Containers
  module Forecasts
		class Container
      extend Dry::Container::Mixin
      
      register 'validate_zipcode', &ValidateZipcode.resolve('validate_zipcode')
      register 'load_cached_forecast', &LoadCachedForecast.resolve('load_cached_forecast')
			register 'resolve_geolocation', &ResolveGeolocation.resolve('resolve_geolocation')
			register 'fetch_weather', &FetchWeather.resolve('fetch_weather')
			register 'persist_forecast_cache', &PersistForecastCache.resolve('persist_forecast_cache')
			register 'build_response', &BuildResponse.resolve('build_response')
    end
  end
end