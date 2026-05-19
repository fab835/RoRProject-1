require 'rails_helper'

RSpec.describe Containers::Forecasts::ValidateZipcode do
  include Dry::Monads[:result]

  subject(:operation) { described_class.resolve('validate_zipcode') }

  it 'normalizes and returns a valid zipcode' do
    result = operation.call(zipcode: ' 60601 ')

    expect(result).to be_success
    expect(result.value!).to eq(zipcode: '60601')
  end

  it 'returns a validation failure for an invalid zipcode' do
    result = operation.call(zipcode: '!')

    expect(result).to be_failure
    expect(result.failure).to eq(type: :validation, errors: { zipcode: ['must be a valid postal code'] })
  end
end
