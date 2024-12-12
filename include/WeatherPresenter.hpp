#pragma once
#include "WeatherData.hpp"
#include <string>

struct WeatherInfo {
    WeatherData data;
    bool isGoodForOutdoor;
    bool hasHighWindWarning;
    bool hasColdWarning;
};

class WeatherPresenter {
public:
    void displayWeather(const WeatherInfo &info, const std::string &locationName) const;
};
