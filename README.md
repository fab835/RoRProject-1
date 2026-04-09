# RoRProject-1

## Requirement:
- Must be done in Ruby on Rails
- Accept an address as input
- Retrieve forecast data for the given zip code. This should include, at minimum, the current temperature (Bonus points - Retrieve high/low and/or extended forecast)
- Display the requested forecast details to the user
- Cache the forecast details for 30 minutes for all subsequent requests by zip codes.
- Display an indicator if the result is pulled from cache.
### Assumptions:
- This project is open to interpretation
- Functionality is a priority over form

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
5. Configure Redis for cache. - OK
6. Create spec. - OK
7. Extra - include humidity and rain forecast. - OK

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

4. (First Run) prepare database - See the command below

## Useful commands

Create and prepare the database:

```bash
docker compose run --rm web bundle exec rails db:prepare
```

Create the database:

```bash
docker compose run --rm web bundle exec rails db:create
```

Migrate the database:

```bash
docker compose run --rm web bundle exec rails db:migrate
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
  "http://localhost:3000/api/forecast/44444"
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
                },
                "extra": {
                    "humidity": 26,
                    "rain": 0.0
                }
            }
        }
	}
```
