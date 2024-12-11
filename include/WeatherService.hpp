#pragma once

#include "WeatherData.hpp"

// Interface for weather services that provide weather data for specified coordinates
class WeatherService {
public:
    virtual ~WeatherService() = default;
    virtual WeatherData getWeatherData(double latitude, double longitude) const = 0;
};
