class Geolocation < ApplicationRecord
  validates :zipcode, presence: true, uniqueness: true
  validates :latitude, :longitude, presence: true
end
