require 'rails_helper'

RSpec.describe Entities::ExtraEntity, type: :entity do
  let(:data) do
    { humidity: 30, rain: 0.0 }
  end

  describe 'initialize' do
    subject(:json) { described_class.new(data).as_json }

    it { expect(json).to eq(data) }
  end
end
