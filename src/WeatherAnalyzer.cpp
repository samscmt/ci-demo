#include "WeatherAnalyzer.hpp"

WeatherAnalyzer::WeatherAnalyzer(WeatherService &weatherService)
    : m_weatherService(weatherService), m_weatherData{0.0, 0.0, false} {
}

WeatherData WeatherAnalyzer::getWeatherData(double latitude, double longitude) {
    m_weatherData = m_weatherService.getWeatherData(latitude, longitude);
    return m_weatherData;
}

WeatherInfo WeatherAnalyzer::getWeatherInfo() const {
    return WeatherInfo{
        m_weatherData,                // current weather data
        isGoodForOutdoorActivities(), // check if weather is good for outdoor activities
        isHighWindWarning(),          // check if there's a high wind warning
        isColdWeatherWarning()        // check if there's a cold temperature warning
    };
}

bool WeatherAnalyzer::isGoodForOutdoorActivities() const {
    return m_weatherData.temperature > 15.0 && m_weatherData.windSpeed < 10.0;
}

bool WeatherAnalyzer::isHighWindWarning() const {
    return m_weatherData.windSpeed > 20.0;
}

bool WeatherAnalyzer::isColdWeatherWarning() const {
    return m_weatherData.temperature < 0.0;
}
