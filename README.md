# Continuous Integration-Demo mit GitHub Actions

Die Demo verwendet ein kleines Beispiel-Projekt in C++, mit dem man Wetterdaten
von vordefinierten Orten über den Dienst open-meteo.com abrufen kann und
basierend auf einer fachlichen Logik Empfehlungen erhält, ob sich das aktuelle
Wetter für Aktivitäten im Freien eignet, z.B. wie folgt:

```text
Esslingen University:
Temperature: 3.3 °C
Wind Speed: 6.4 km/h
The weather is not ideal for outdoor activities.

Sunnyvale, California:
Temperature: 6.2 °C
Wind Speed: 2.8 km/h
The weather is not ideal for outdoor activities.
```

## Projektstruktur

Das Projekt verwendet die Header-only-Bibliotheken `nlohmann::json`, `httplib`
und `catch2` (Version 2).

```text
.
├── LICENSE
├── Makefile
├── README.md
├── include
│   ├── OpenMeteoWeatherService.hpp
│   ├── WeatherAnalyzer.hpp
│   ├── WeatherData.hpp
│   ├── WeatherPresenter.hpp
│   ├── WeatherService.hpp
│   ├── httplib.h
│   └── json.hpp
├── main.cpp
├── src
│   ├── OpenMeteoWeatherService.cpp
│   ├── WeatherAnalyzer.cpp
│   └── WeatherPresenter.cpp
└── test
    ├── catch.hpp
    └── testWeatherAnalyzer.cpp
```

## Übersetzen und Ausführen des Projekts

Das Repository enthält bereits ein Makefile, mittels dessen man sich das Projekt
übersetzen lassen und ausführen kann.

```text
% make
g++ -Wall -Wextra -Wpedantic -std=c++17 -g -O0 -I include -c main.cpp -o build/main.o
g++ -Wall -Wextra -Wpedantic -std=c++17 -g -O0 -I include -c src/OpenMeteoWeatherService.cpp -o build/OpenMeteoWeatherService.o
g++ -Wall -Wextra -Wpedantic -std=c++17 -g -O0 -I include -c src/WeatherAnalyzer.cpp -o build/WeatherAnalyzer.o
g++ -Wall -Wextra -Wpedantic -std=c++17 -g -O0 -I include -c src/WeatherPresenter.cpp -o build/WeatherPresenter.o
g++ -Wall -Wextra -Wpedantic -std=c++17 -g -O0 -I include build/main.o  build/OpenMeteoWeatherService.o  build/WeatherAnalyzer.o  build/WeatherPresenter.o  -o build/mainDebug
```

```text
% make execute
./build/mainDebug
Esslingen University:
Temperature: 3.3 °C
Wind Speed: 6.4 km/h
The weather is not ideal for outdoor activities.
Sunnyvale, California:
Temperature: 6.2 °C
Wind Speed: 2.8 km/h
The weather is not ideal for outdoor activities.
```

Außerdem kann man mittels `make test` auch die zugehörigen Unit-Tests ausführen lassen:

```text
% make test
g++ -Wall -Wextra -Wpedantic -std=c++17 -g -O0 -I include -c test/testWeatherAnalyzer.cpp -o build/tests/testWeatherAnalyzer.o
g++ -Wall -Wextra -Wpedantic -std=c++17 -g -O0 -I include  build/tests/testWeatherAnalyzer.o  build/OpenMeteoWeatherService.o  build/WeatherAnalyzer.o  build/WeatherPresenter.o  -o build/tests/testDebug
./build/tests/testDebug
===============================================================================
All tests passed (9 assertions in 3 test cases)
```

## GitHub Actions

Das Projekt enthält eine GitHub Actions-Datei `ci.yaml`, in der die
Konfiguration für eine Continuous Integration (CI) Pipeline für ein C++-Projekt
enthalten ist. Die Pipeline führt verschiedene Überprüfungen und Builds aus,
wenn Code in den `main` Branch gepusht oder ein Pull Request erstellt wird.

### Trigger

Die Pipeline wird bei Push-Events und Pull Requests auf den `main` Branch
ausgelöst.

### Jobs

1. Format-Check

    Dieser Job stellt sicher, dass der gesamte C++-Code einheitlich formatiert
    ist. Dies hilft, den Code sauber und lesbar zu halten und verhindert
    Formatierungsprobleme, die durch unterschiedliche Entwicklungsumgebungen
    entstehen könnten.

    Der Job führt hierfür `clang-format` aus, um den Code-Stil zu überprüfen und
    ggf. zu korrigieren. Die Regeln dazu befinden sich in der Datei
    `.clang-format` des Repositorys.

2. Cppcheck-Analyse

    Dieser Job führt eine statische Code-Analyse mit dem Tool `cppcheck` durch.
    `cppcheck` überprüft den Code auf gängige Fehler wie z.B. Pufferüberläufe,
    nicht initialisierte Variablen und mögliche Nullzeiger-Dereferenzierungen.

    Anschließend wird ein Bericht erstellt und unter dem Namen
    `cppcheck_report.txt` abgelegt.

3. Statische Analyse

    Mit `clang-tidy` wird eine weitere statische Analyse durchgeführt.
    `clang-tidy` ist ein leistungsfähiges Tool, das nicht nur einfache Fehler,
    sondern auch komplexere Probleme und Anti-Pattern im Code erkennen kann.

    Die Regeln hierfür befinden sich in der Datei `.clang-tidy` des Repositorys.

4. Build

    Dieser Job übersetzt das gesamte Projekt gemäß dem im Repository
    befindlichen `Makefile`, um sicherzustellen, dass der Code fehlerfrei gebaut
    werden kann. Dies umfasst das Übersetzen der Quellcode-Dateien und das
    Erstellen der ausführbaren Dateien oder Bibliotheken.

5. Test

    Der Test-Job führt alle definierten Tests im Projekt aus. Hierzu wird
    ebenfalls das im Repository befindliche `Makefile` verwendet, um die Tests
    zu bauen. Dies umfasst in diesem Beispiel-Projekt nur Unit-Tests, könnte
    aber auch Integrationstests und möglicherweise andere Arten von Tests
    beinhalten.

    Das Ergebnis der Tests wird in einer Datei `test_results.xml` abgelegt und
    an eine `JUnit Report Action` zur besseren Veranschaulichung weitergeleitet.
