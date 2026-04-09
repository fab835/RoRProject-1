module WeatherApi
  class Client
    BASE_URL = 'https://api.open-meteo.com/v1/forecast'.freeze

    def initialize(connection: default_connection)
      @connection = connection
    end

    def fetch(latitude:, longitude:)
      response = connection.get(uri(latitude:, longitude:))

      normalize_response(response)
    rescue ArgumentError => exception
      raise DefaultError.new(exception.message, :external_api_error)
    rescue DefaultError => exception
      raise DefaultError.new(exception.errors, exception.type)
    end

    private

    attr_reader :connection

    def uri(latitude:, longitude:)
      params = {
        latitude:,
        longitude:,
        current: 'temperature_2m,relative_humidity_2m,rain',
        daily: 'temperature_2m_min,temperature_2m_max',
        timezone: 'auto'
      }

      "?#{params.to_query}"
    end

    def normalize_response(response)
      response = JSON.parse(response.body)
      payload = weather_payload(response)

      {
        min: Float(payload[:min]),
        max: Float(payload[:max]),
        current: Float(payload[:current]),
        unit: payload[:unit],
        humidity: payload[:humidity],
        rain: payload[:rain]
      }
    end

    def weather_payload(response)
      payload = {
        current: response.dig('current', 'temperature_2m'), min: response.dig('daily', 'temperature_2m_min', 0),
        max: response.dig('daily', 'temperature_2m_max', 0),
        unit: normalize_unit(response.dig('current_units', 'temperature_2m')),
        humidity: response.dig('current', 'relative_humidity_2m'), rain: response.dig('current', 'rain')
      }

      if payload.values_at(:current, :min, :max).any?(&:nil?)
        raise DefaultError.new('Incomplete forecast payload', :external_api_error)
      end

      payload
    end

    def normalize_unit(unit)
      unit == '°C' ? 'celsius' : unit.to_s
    end

    def default_connection
      Faraday.new(url: BASE_URL) do |conn|
        conn.headers['User-Agent'] = 'my-app'
        conn.headers['Accept-Language'] = 'en'

        conn.adapter Faraday.default_adapter
      end
    end
  end
end
