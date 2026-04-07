module Api
  class ApiController < ActionController::API
    include ActionController::MimeResponds

    before_action :authenticate_request!

    private

    def render_object(data)
      render json: { data: }
    end

    def render_error(error)
      render json: { data: error_payload(error) }, status: error_status(error)
    rescue StandardError
      render json: { data: { error: } }, status: :bad_gateway
    end

    def authenticate_request!
      expected_token = ENV.fetch('INTERNAL_API_AUTH_TOKEN', nil)
      provided_token = request.authorization&.split&.last

      return if expected_token.present? && ActiveSupport::SecurityUtils.secure_compare(provided_token.to_s,
                                                                                       expected_token)

      render json: { data: { error: 'Unauthorized' } }, status: :unauthorized
    end

    def error_payload(error)
      {
        error: error_message(error),
        details: error[:errors] || error[:message]
      }.compact
    end

    def error_message(error)
      return 'Invalid params' if error[:type] == :validation
      return 'Data not found' if error[:type] == :not_found

      'Unexpected error'
    end

    def error_status(error)
      return :unprocessable_content if error[:type] == :validation
      return :not_found if error[:type] == :not_found

      :bad_gateway
    end
  end
end
