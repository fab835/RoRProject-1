
  module GeolocationApi
    class Client
      BASE_URL = "https://api.zippopotam.us/us".freeze

      def initialize(http_client: Http::JsonClient.new)
        @http_client = http_client
      end

      def fetch(zipcode:)
        response = http_client.get(URI("#{BASE_URL}/#{zipcode}"))

        place = response.value!["places"]&.first
        raise DefaultError.new("Zipcode not found", :not_found) if place.blank?

        return {
          latitude: Float(place["latitude"]),
          longitude: Float(place["longitude"])
        }
      rescue ArgumentError => e
        raise DefaultError.new(e.message, :external_api_error)
      rescue DefaultError => e
        raise DefaultError.new(e.type === :not_found ? "Zipcode not found": e.errors, e.type)
      end

      private

      attr_reader :http_client
    end
  end
