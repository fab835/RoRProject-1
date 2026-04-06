
class ForecastResponseSerializer
  include FastJsonapi::ObjectSerializer

  set_id { |_| nil } 

  attributes :zipcode, :cached_result

  attribute :forecast do |object|
    ForecastSerializer.new(object.forecast).serializable_hash[:data][:attributes]
  end

  def self.serialize(object)
    {
      data: new(object).serializable_hash[:data][:attributes]
    }
  end
end
