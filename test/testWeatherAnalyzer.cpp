#define CATCH_CONFIG_MAIN
#include "catch.hpp"

#include "WeatherAnalyzer.hpp"
#include "WeatherData.hpp"
#include "WeatherPresenter.hpp"

// Mock implementation of WeatherService for testing purposes
class MockWeatherService : public WeatherService {
public:
    explicit MockWeatherService(const WeatherData &mockData)
        : m_mockData(mockData) {
    }

    WeatherData getWeatherData(double /*latitude*/, double /*longitude*/) const override {
        return m_mockData;
    }

private:
    WeatherData m_mockData;
};

TEST_CASE("WeatherAnalyzer correctly identifies good weather for outdoor activities", "[WeatherAnalyzer]") {
    // Arrange: Mock weather data that should be ideal for outdoor activities
    WeatherData goodWeather = { 20.0, 5.0, true }; // 20°C and 5 km/h wind
    MockWeatherService mockService(goodWeather);
    WeatherAnalyzer analyzer(mockService);

    // Act: Get weather info and check conditions
    analyzer.getWeatherData(0.0, 0.0); // coordinates don't matter for mock
    WeatherInfo info = analyzer.getWeatherInfo();

    // Assert
    REQUIRE(info.isGoodForOutdoor == true);
    REQUIRE(info.hasHighWindWarning == false);
    REQUIRE(info.hasColdWarning == false);
}

TEST_CASE("WeatherAnalyzer detects high wind warning", "[WeatherAnalyzer]") {
    // Arrange: Mock weather data with high wind speed
    WeatherData highWind = { 15.0, 55.0, true }; // 15°C and 55 km/h wind
    MockWeatherService mockService(highWind);
    WeatherAnalyzer analyzer(mockService);

    // Act: Get weather info and check warnings
    analyzer.getWeatherData(0.0, 0.0); // coordinates don't matter for mock
    WeatherInfo info = analyzer.getWeatherInfo();

    // Assert
    REQUIRE(info.hasHighWindWarning == true);
    REQUIRE(info.isGoodForOutdoor == false);
    REQUIRE(info.hasColdWarning == false);
}

TEST_CASE("WeatherAnalyzer detects cold weather warning", "[WeatherAnalyzer]") {
    // Arrange: Mock weather data with cold temperature
    WeatherData coldWeather = { -5.0, 5.0, true }; // -5°C and 5 km/h wind
    MockWeatherService mockService(coldWeather);
    WeatherAnalyzer analyzer(mockService);

    // Act: Get weather info and check warnings
    analyzer.getWeatherData(0.0, 0.0); // coordinates don't matter for mock
    WeatherInfo info = analyzer.getWeatherInfo();

    // Assert
    REQUIRE(info.hasColdWarning == true);
    REQUIRE(info.hasHighWindWarning == false);
    REQUIRE(info.isGoodForOutdoor == false);
}