module WeatherApi
  class Client
    BASE_URL = 'https://api.open-meteo.com/v1/forecast'.freeze

    def initialize(http_client: Http::JsonClient.new)
      @http_client = http_client
    end

    def fetch(latitude:, longitude:)
      response = http_client.get(uri(latitude:, longitude:))
      normalize_response(response)
    rescue ArgumentError => exception
      raise DefaultError.new(exception.message, :external_api_error)
    rescue DefaultError => exception
      raise DefaultError.new(exception.errors, exception.type)
    end

    private

    attr_reader :http_client

    def uri(latitude:, longitude:)
      params = {
        latitude: latitude,
        longitude: longitude,
        current: 'temperature_2m',
        daily: 'temperature_2m_min,temperature_2m_max',
        timezone: 'auto'
      }

      URI("#{BASE_URL}?#{params.to_query}")
    end

    def normalize_response(response)
      payload = weather_payload(response)

      {
        min: Float(payload[:min]),
        max: Float(payload[:max]),
        current: Float(payload[:current]),
        unit: payload[:unit]
      }
    end

    def weather_payload(response)
      payload = {
        current: response.dig('current', 'temperature_2m'),
        min: response.dig('daily', 'temperature_2m_min', 0),
        max: response.dig('daily', 'temperature_2m_max', 0),
        unit: normalize_unit(response.dig('current_units', 'temperature_2m'))
      }

      if payload.values_at(:current, :min, :max).any?(&:nil?)
        raise DefaultError.new('Incomplete forecast payload', :external_api_error)
      end

      payload
    end

    def normalize_unit(unit)
      unit == '°C' ? 'celsius' : unit.to_s
    end
  end
end
