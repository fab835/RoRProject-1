require 'rails_helper'

RSpec.describe Geolocation, type: :model do
  subject(:geolocation) { build(:geolocation) }

  it 'is valid with the factory' do
    expect(geolocation).to be_valid
  end

  it 'requires a zipcode' do
    geolocation.zipcode = nil

    expect(geolocation).not_to be_valid
    expect(geolocation.errors[:zipcode]).to include("can't be blank")
  end

  it 'requires latitude and longitude' do
    geolocation.latitude = nil
    geolocation.longitude = nil

    expect(geolocation).not_to be_valid
    expect(geolocation.errors[:latitude]).to include("can't be blank")
    expect(geolocation.errors[:longitude]).to include("can't be blank")
  end

  it 'validates zipcode uniqueness' do
    existing_geolocation = create(:geolocation)
    geolocation.zipcode = existing_geolocation.zipcode

    expect(geolocation).not_to be_valid
    expect(geolocation.errors[:zipcode]).to include('has already been taken')
  end
end
