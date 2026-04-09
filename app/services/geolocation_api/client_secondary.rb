module GeolocationApi
  class ClientSecondary
    BASE_URL = 'https://api.zippopotam.us'.freeze

    def initialize(connection: default_connection)
      @connection = connection
    end

    def fetch(zipcode:)
      normalize_place(fetch_place(zipcode:))
    rescue ArgumentError => exception
      raise DefaultError.new(exception.message, :external_api_error)
    rescue DefaultError => exception
      raise DefaultError.new(error_message(exception), exception.type)
    end

    private

    attr_reader :connection

    def fetch_place(zipcode:, country: 'us')
      response = connection.get("/#{country}/#{zipcode}")
      status = response.status
      raise DefaultError.new('Zipcode not found', :not_found) if status < 200 || status >= 300

      data = JSON.parse(response.body)
      place = data['places']&.first

      raise DefaultError.new('Zipcode not found', :not_found) if place.blank?

      place
    end

    def normalize_place(place)
      {
        latitude: Float(place['latitude']),
        longitude: Float(place['longitude']),
        display_name: "#{place['place name']} #{place['state abbreviation']}"
      }
    end

    def error_message(exception)
      return 'Zipcode not found' if exception.type == :not_found

      exception.errors
    end

    def default_connection
      Faraday.new(url: BASE_URL) do |conn|
        conn.adapter Faraday.default_adapter
      end
    end
  end
end
