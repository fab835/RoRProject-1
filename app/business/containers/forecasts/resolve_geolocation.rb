module Containers
  module Forecasts
    class ResolveGeolocation < ApplicationContainer
      @client = ::GeolocationApi::Client.new

      register 'resolve_geolocation' do |input|
        if input[:cached_payload].present?
          Dry::Monads::Success(input)
        else
          zipcode = input.fetch(:zipcode)
          geolocation = Geolocation.find_by(zipcode:)
          if geolocation.present?
            Dry::Monads::Success(input.merge(geolocation:)) 
          else
            response = @client.fetch(zipcode:)
            raise StandardError, response.failure if response.failure?

            geolocation = Geolocation.create!(
              zipcode:,
              latitude: response.value![:latitude],
              longitude: response.value![:longitude]
            )

            Dry::Monads::Success(input.merge(geolocation:))
          end
        end
      rescue DefaultError => exception
        Dry::Monads::Failure(type: exception.type, message: exception.errors)
      rescue StandardError => exception
        Dry::Monads::Failure(type: :not_found, message: exception.message)
      end
    end
  end
end
