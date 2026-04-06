module Api
  class ForecastsController < ApiController
    def show
      result = ::Transactions::Forecasts::FetchForecast.new.call(zipcode: permit_params[:zipcode])

      if result.success?
        render_object(ForecastResponseSerializer.serialize(result.value!))
      else
        render_error(result.failure)
      end
    end

    private

    def permit_params
      params.permit(:zipcode)
    end
  end
end
