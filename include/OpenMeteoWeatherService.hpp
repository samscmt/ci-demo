#pragma once

#include "WeatherData.hpp"
#include "WeatherService.hpp"

#include "httplib.h"
#include "json.hpp"

class OpenMeteoWeatherService : public WeatherService {
public:
    WeatherData getWeatherData(double latitude, double longitude) const;
};
