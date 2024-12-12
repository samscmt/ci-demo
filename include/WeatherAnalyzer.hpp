#pragma once
#include "WeatherData.hpp"
#include "WeatherPresenter.hpp"
#include "WeatherService.hpp"

class WeatherAnalyzer {
public:
    explicit WeatherAnalyzer(WeatherService &weatherService);

    WeatherData getWeatherData(double latitude, double longitude);
    WeatherInfo getWeatherInfo() const;

    bool isGoodForOutdoorActivities() const;
    bool isHighWindWarning() const;
    bool isColdWeatherWarning() const;

private:
    WeatherService &m_weatherService;
    WeatherData m_weatherData;
};
