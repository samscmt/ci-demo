#pragma once

#include "WeatherService.hpp"
#include "WeatherData.hpp"

#include "httplib.h"
#include "json.hpp"

class OpenMeteoWeatherService : public WeatherService {
public:
    WeatherData getWeatherData(double latitude, double longitude) const;
};