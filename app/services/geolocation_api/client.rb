module GeolocationApi
  class Client
    BASE_URL = 'https://api.zippopotam.us/us'.freeze

    def initialize(http_client: Http::JsonClient.new)
      @http_client = http_client
    end

    def fetch(zipcode:)
      normalize_place(fetch_place(zipcode:))
    rescue ArgumentError => exception
      raise DefaultError.new(exception.message, :external_api_error)
    rescue DefaultError => exception
      raise DefaultError.new(error_message(exception), exception.type)
    end

    private

    attr_reader :http_client

    def fetch_place(zipcode:)
      response = http_client.get(URI("#{BASE_URL}/#{ERB::Util.url_encode(zipcode)}"))
      place = response['places']&.first

      raise DefaultError.new('Zipcode not found', :not_found) if place.blank?

      place
    end

    def normalize_place(place)
      {
        latitude: Float(place['latitude']),
        longitude: Float(place['longitude'])
      }
    end

    def error_message(exception)
      return 'Zipcode not found' if exception.type == :not_found

      exception.errors
    end
  end
end
