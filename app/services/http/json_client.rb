require "json"
require "net/http"

module Http
  class JsonClient
    def get(uri)
      response = Net::HTTP.get_response(uri)

      raise DefaultError.new("Unexpected response status #{response.code}", response.code.to_i === 404 ? :not_found : :external_api_error) unless response.is_a?(Net::HTTPSuccess)

      return JSON.parse(response.body)
    rescue JSON::ParserError => e
      raise DefaultError.new(e.message, :external_api_error)
    end
  end
end
