# RoRProject-1

## Requirement 1:
● Must be done in Ruby on Rails
● Accept an address as input
● Retrieve forecast data for the given zip code. This should include, at minimum, the
current temperature (Bonus points - Retrieve high/low and/or extended forecast)
● Display the requested forecast details to the user
● Cache the forecast details for 30 minutes for all subsequent requests by zip codes.
● Display an indicator if the result is pulled from cache.
Assumptions:
● This project is open to interpretation
● Functionality is a priority over form

## Requirement 2: 
Develop API services capable of retrieving weather forecasts for a specific location. The application should:
1. Accept a zip code from users as input.
2. Provide the current temperature at the requested location as its primary output.
3. Offer additional details, such as the highest and lowest temperatures, and an extended forecast, as bonus features.
4. Implement caching to store forecast details for a duration of 15 minutes for subsequent requests using the same zip code.
5. Display an indicator to notify users if the result is retrieved from the cache.
The latitude and longitude for a zip code can be fetched using any open-source geocoding API service. Then, look up the
weather for the latitude and longitude using another open source API available for that. Both services should be
open-source and do not require an API key. As always, be mindful of the number and frequency of requests you are
making to these services.
You should adhere to the Spring/Spring Boot patterns you are familiar with, including the utilization of Controllers, Models,
Services, and Repositories.

## TODO
1. Setup the rails project. - OK
2. Create Geolocations model to save latitude and longitude of a zip code - OK
3. Create a service label to make a call to the geolocation and wather API. - OK
4. Create a API path to request the forecast info. - OK
   - Search for the geolocation for the zipcode. (saved in system or using an external API)
   - Save geolocation if it's new.
   - Search for the forecast by longitude and latitude.
   - Cache the API results for 30 minutes.
   - Payload:
    ```json
        {"data": { 
            "zipcode": "03456",
            "cachedResult": true,
            "forecast": {
                "temperature": {
                    "min": 20,
                    "max": 28,
                    "current": 25,
                    "unit": "celsius"
                } 
            },
        }}
    ```
6. Configure Redis for cache. - OK
5. Create spec. - OK

## Stack

- Ruby on Rails 8
- PostgreSQL 16
- Redis 7 for caching

## Start the project

1. Create the .env file, you can use the .env.example

2. Build and start the containers:
```bash
docker compose up --build
```

3. app runing at [http://localhost:3000](http://localhost:3000).

## Useful commands

Create and prepare the database:

```bash
docker compose run --rm web bundle exec rails db:prepare
```

Run the test suite:

```bash
docker compose run --rm -e RAILS_ENV=test web bundle exec rspec
```

Run RuboCop:

```bash
docker compose run --rm web bundle exec rubocop
```

## API authentication

Set the internal API token in `.env`:

```bash
INTERNAL_API_AUTH_TOKEN=development-token
```

## Endpoints
Call the forecast endpoint with the bearer token:

```bash
curl -H "Authorization: Bearer development-token" \
  "http://localhost:3000/api/forecast?zipcode=44444"
```

payload: 
```JSON
    {
        "data": {
            "zipcode": "44422",
            "cachedResult": true,
            "forecast": {
                "temperature": {
                    "min": 0.6,
                    "max": 8.8,
                    "current": 6.9,
                    "unit": "celsius"
                }
            }
        }
	}
```
