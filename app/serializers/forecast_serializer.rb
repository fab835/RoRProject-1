
class ForecastSerializer
  include FastJsonapi::ObjectSerializer

  set_id { |_| nil } 

  attribute :temperature do |object|
    temperature = object[:temperature] || object["temperature"]

    TemperatureSerializer
      .new(OpenStruct.new(temperature))
      .serializable_hash[:data][:attributes]
  end
end
