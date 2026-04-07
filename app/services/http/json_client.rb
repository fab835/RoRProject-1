require 'json'
require 'net/http'

module Http
  class JsonClient
    def get(uri)
      response = Net::HTTP.get_response(uri)

      unless response.is_a?(Net::HTTPSuccess)
        raise DefaultError.new("Unexpected response status #{response.code}",
                               response.code.to_i == 404 ? :not_found : :external_api_error)
      end

      JSON.parse(response.body)
    rescue JSON::ParserError => exception
      raise DefaultError.new(exception.message, :external_api_error)
    end
  end
end
