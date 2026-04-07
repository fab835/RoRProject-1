module Containers
  module Forecasts
    class BuildResponse < ApplicationContainer
      register 'build_response' do |input|
        payload = if input[:cached_payload].present?
                    input.fetch(:cached_payload).merge(cached_result: true)
                  else
                    input.fetch(:response_payload)
                  end

        Dry::Monads::Success(Entities::ForecastEntity.new(payload))
      rescue StandardError => exception
        Dry::Monads::Failure(type: :internal_error, message: exception.message)
      end
    end
  end
end
