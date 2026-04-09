class ExtraSerializer
  include FastJsonapi::ObjectSerializer

  set_id { |_| nil }

  attributes :humidity, :rain
end
