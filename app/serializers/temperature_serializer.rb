class TemperatureSerializer
  include FastJsonapi::ObjectSerializer

  set_id { |_| nil }

  attributes :min, :max, :current, :unit
end
