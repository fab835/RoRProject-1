module Api
  class ApiController < ActionController::API
    include ActionController::MimeResponds

    before_action :authenticate_request!

    private

    def render_object(data)
      render json: { data: }
    end

    def render_error(error)
      begin
        case error[:type]
        when :validation
          render json: { data: { error: "Invalid params", details: error[:errors] } }, status: :unprocessable_content
        when :not_found
          render json: { data: { error: "Data not found", details: error[:errors] || error[:message] } }, status: :not_found
        else
          render json: { data: { error: "Unexpected error", details: error[:errors] || error[:message] } }, status: :bad_gateway
        end
      rescue => e
        render json: { data: { error: } }, status: :bad_gateway
      end
    end

    def authenticate_request!
      expected_token = ENV.fetch("INTERNAL_API_AUTH_TOKEN", nil)
      provided_token = request.authorization&.split&.last

      return if expected_token.present? && ActiveSupport::SecurityUtils.secure_compare(provided_token.to_s, expected_token)

      render json: { data: { error: "Unauthorized" } }, status: :unauthorized
    end
  end
end
