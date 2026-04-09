module Entities
  class ExtraEntity < ApplicationEntity
    attribute :humidity, Types::Float | Types::Integer
    attribute :rain, Types::Float | Types::Integer

    def as_json(*)
      {
        humidity:,
        rain:
      }
    end
  end
end
