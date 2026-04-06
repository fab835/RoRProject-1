module Containers
  module Forecasts
    class ValidateZipcode < ApplicationContainer
      @validator = Validators::ZipcodeValidator.new

      register 'validate_zipcode' do |input|
        zipcode = input.fetch(:zipcode).to_s.strip
        validation = @validator.call(zipcode:)
        
        raise DefaultError.new(validation.errors.to_h, :validation) if validation.failure?

        Dry::Monads::Success(input.merge(zipcode:))
      rescue DefaultError => exception
        Dry::Monads::Failure(type: exception.type, errors: exception.errors)
      rescue StandardError => exception
        Dry::Monads::Failure(type: :internal_error, message: exception.message)
      end
    end
  end
end
