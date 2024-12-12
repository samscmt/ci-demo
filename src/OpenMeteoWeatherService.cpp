#include "OpenMeteoWeatherService.hpp"
#include <limits>

using json = nlohmann::json;

// Fetches current weather data from the Open-Meteo API for specified geographic
// coordinates
WeatherData OpenMeteoWeatherService::getWeatherData(double latitude, double longitude) const {
    httplib::Client client("http://api.open-meteo.com");
    std::string path = "/v1/forecast?latitude=" + std::to_string(latitude)
                       + "&longitude=" + std::to_string(longitude) + "&current_weather=true";

    auto res = client.Get(path.c_str());

    if (res && res->status == 200) {
        json response = json::parse(res->body, nullptr, false);
        if (!response.is_discarded() && response.contains("current_weather")) {
            const double temperature = response["current_weather"]["temperature"].get<double>();
            const double windSpeed = response["current_weather"]["windspeed"].get<double>();
            return {temperature, windSpeed, true};
        }
    }

    return {std::numeric_limits<double>::quiet_NaN(),
            std::numeric_limits<double>::quiet_NaN(),
            false};
}
