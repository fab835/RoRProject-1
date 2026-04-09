require 'rails_helper'

RSpec.describe Entities::TemperatureEntity, type: :entity do
  let(:data) do
    { min: 19.4, max: 20.0, current: 19.9, unit: 'censius' }
  end

  describe 'initialize' do
    subject(:json) { described_class.new(data).as_json }

    it { expect(json).to eq(data) }
  end
end
