module Entities
  class ForecastEntity < ApplicationEntity
    attribute :zipcode, Types::String
    attribute :cached_result, Types::Bool
    attribute :forecast, Types::Hash

    def as_json(*)
      {
        zipcode: zipcode,
        cachedResult: cached_result,
        forecast: forecast
      }
    end
  end
end