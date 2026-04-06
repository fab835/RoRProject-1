module Entities
  class TemperatureEntity < ApplicationEntity
    attribute :min, Types::Float
    attribute :max, Types::Float
    attribute :current, Types::Float
    attribute :unit, Types::String

    def as_json(*)
      {
        min:,
        max:,
        current:,
        unit:
      }
    end
  end
end
