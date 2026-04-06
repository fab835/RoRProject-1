module WeatherApi
  class Client
    BASE_URL = "https://api.open-meteo.com/v1/forecast".freeze

    def initialize(http_client: Http::JsonClient.new)
      @http_client = http_client
    end

    def fetch(latitude:, longitude:)
      response = http_client.get(uri(latitude:, longitude:))

      body = response.value!
      current = body.dig("current", "temperature_2m")
      min = body.dig("daily", "temperature_2m_min", 0)
      max = body.dig("daily", "temperature_2m_max", 0)
      unit = body.dig("current_units", "temperature_2m") == "°C" ? "celsius" : body.dig("current_units", "temperature_2m").to_s

      raise DefaultError.new("Incomplete forecast payload", :external_api_error) if [ current, min, max ].any?(&:nil?)

      Success(
        min: Float(min),
        max: Float(max),
        current: Float(current),
        unit:
      )
    rescue ArgumentError => e
      raise DefaultError.new(e.message, :external_api_error)
    rescue DefaultError => e
      raise DefaultError.new(e.type === :not_found ? "Zipcode not found": e.errors, e.type)
    end

    private

    attr_reader :http_client

    def uri(latitude:, longitude:)
      params = {
        latitude: latitude,
        longitude: longitude,
        current: "temperature_2m",
        daily: "temperature_2m_min,temperature_2m_max",
        timezone: "auto"
      }

      URI("#{BASE_URL}?#{params.to_query}")
    end
  end
end
