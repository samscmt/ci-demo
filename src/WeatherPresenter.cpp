#include "WeatherPresenter.hpp"
#include <iostream>

void WeatherPresenter::displayWeather(const WeatherInfo &info, const std::string &locationName) const {
    std::cout << locationName << ":\n";

    if (info.data.success) {
        std::cout << "Temperature: " << info.data.temperature << " °C\n"
            << "Wind Speed: " << info.data.windSpeed << " km/h\n";

        if (info.isGoodForOutdoor) {
            std::cout << "It's a good day for outdoor activities!\n";
        } else {
            std::cout << "The weather is not ideal for outdoor activities.\n";
        }

        if (info.hasHighWindWarning) {
            std::cout << "Warning: High winds! Be cautious with outdoor activities.\n";
        }

        if (info.hasColdWarning) {
            std::cout << "Warning: Freezing temperatures! Dress warmly.\n";
        }
    } else {
        std::cout << "Unable to retrieve weather data for " << locationName << ".\n";
    }
}
