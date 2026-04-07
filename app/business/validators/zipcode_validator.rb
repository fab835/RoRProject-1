module Validators
  class ZipcodeValidator < Dry::Validation::Contract
    params do
      required(:zipcode).filled(:string)
    end

    rule(:zipcode) do
      normalized = value.to_s.strip

      key.failure('must be a valid postal code') unless normalized.match?(/\A\p{Alnum}[\p{Alnum}\s-]{1,10}\p{Alnum}\z/u)
    end
  end
end
