require 'rails_helper'

RSpec.describe Entities::ForecastEntity, type: :entity do
  let(:data) do
    {
      zipcode: '11111',
      cached_result: false,
      forecast: { something_here: 'no validation' }
    }
  end

  describe 'initialize' do
    subject(:json) { described_class.new(data).as_json }

    it do
      expect(json).to eq(
        {
          zipcode: '11111', cachedResult: false,
          forecast: { something_here: 'no validation' }
        }
      )
    end
  end
end
