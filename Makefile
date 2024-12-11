# Standardeinstellungen für Debug-Modus, Warn-Modus und ob Warnungen
# vom Compiler als Fehler angesehen werden sollen
# Falls nicht gewünscht, kann man bspw. angeben:
# make DEBUG=0 ENABLE_WARNINGS=0 WARNINGS_AS_ERRORS=1
DEBUG ?= 1
ENABLE_WARNINGS ?= 1
WARNINGS_AS_ERRORS ?= 0

# Welcher C++-Compiler soll genutzt werden
CXX = g++
# Nach welchem C++-Standard soll übersetzt werden
CXX_STANDARD = c++17

# Die eigenen Headerdateien (.h) sollen in einem "include"-Verzeichnis liegen
INCLUDE_DIR = include
# Die Quelldateien (.cpp) sollen in einem "src"-Verzeichnis liegen
SOURCE_DIR = src
# Die Test-Quelldateien (.cpp) sollen in einem "test"-Verzeichnis liegen
TEST_DIR = test
BUILD_DIR = build
TEST_BUILD_DIR = $(BUILD_DIR)/tests

### Ab hier muss man eigentlich nichts mehr ändern

# Compiler-Optionen für ENABLE_WARNINGS
ifeq ($(ENABLE_WARNINGS), 1)
	CXX_WARNINGS = -Wall -Wextra -Wpedantic
else
	CXX_WARNINGS =
endif

# Compiler-Optionen für WARNINGS_AS_ERRORS
ifeq ($(WARNINGS_AS_ERRORS), 1)
	CXX_WARNINGS += -Werror
endif

# CXXFLAGS enthält letztlich, welche Warnungen und welcher C++-Standard verwendet
# werden sollen
CXXFLAGS = $(CXX_WARNINGS) -std=$(CXX_STANDARD)

# CPPFLAGS ist für den Präprozessor
CPPFLAGS = -I $(INCLUDE_DIR)

# Linker-Optionen (Windows-spezifische Bibliothek einbinden)
ifeq ($(OS),Windows_NT)
	LDFLAGS += -lws2_32
endif


# Falls im Debug-Modus, dann Übersetzen mit Debug-Symbolen (-g) und
# mit niedrigster Optimierungsstufe (-O0)
ifeq ($(DEBUG), 1)
	CXXFLAGS += -g -O0
	EXECUTABLE_NAME = mainDebug
	TEST_EXECUTABLE_NAME = testDebug
# Andernfalls mit höchster Optimierungsstufe (-O3)
else
	CXXFLAGS += -O3
	EXECUTABLE_NAME = mainRelease
	TEST_EXECUTABLE_NAME = testRelease
endif

# Zusammensetzen der Optionen für den Compiler-Call
CXX_COMPILER_CALL = $(CXX) $(CXXFLAGS) $(CPPFLAGS)

# CXX_SOURCES soll alle .cpp-Dateien unterhalb von src/ enthalten
CXX_SOURCES = $(wildcard $(SOURCE_DIR)/*.cpp)
# Die Objektdateien sollen dasselbe Präfix wie die Quelldateien haben
# aber die Endung .o und im Verzeichnis "build" abgelegt werden
CXX_OBJECTS = $(patsubst $(SOURCE_DIR)/%.cpp, $(BUILD_DIR)/%.o, $(CXX_SOURCES))

# Haupt-Objektdatei für main.cpp im obersten Verzeichnis
MAIN_OBJECT = $(BUILD_DIR)/main.o

# TEST_SOURCES soll alle .cpp-Dateien unterhalb von test/ enthalten
TEST_SOURCES = $(wildcard $(TEST_DIR)/*.cpp)
# Die Test-Objektdateien sollen dasselbe Präfix wie die Test-Quelldateien haben
# aber die Endung .o und im Verzeichnis "build/tests" abgelegt werden
TEST_OBJECTS = $(patsubst $(TEST_DIR)/%.cpp, $(TEST_BUILD_DIR)/%.o, $(TEST_SOURCES))

##############
## TARGETS  ##
##############

# Das "all"-Target soll anzeigen, dass damit alles gebaut wird
# Hinter jedem Target stehen die Dependencies
# Da es das erste Target in diesem Makefile ist, wird es automatisch
# durch den Aufruf "make" aufgerufen
all: create build

# Das '@'-Symbol steht hier, damit der Befehl zwar ausgeführt aber nicht
# mit ausgegeben wird
# Mit der Option '-p' wird das Verzeichnis "build" nur angelegt, wenn es
# noch nicht existiert
create:
ifeq ($(OS),Windows_NT)
	@if not exist "$(BUILD_DIR)" mkdir "$(BUILD_DIR)"
	@if not exist "$(TEST_BUILD_DIR)" mkdir "$(TEST_BUILD_DIR)"
else
	@mkdir -p $(BUILD_DIR) $(TEST_BUILD_DIR)
endif


# Haupt-Build für das Programm
build: create $(MAIN_OBJECT) $(CXX_OBJECTS)
	$(CXX_COMPILER_CALL) $(MAIN_OBJECT) $(CXX_OBJECTS) $(LDFLAGS) -o $(BUILD_DIR)/$(EXECUTABLE_NAME)

# Ausführen des Hauptprogramms
execute:
	./$(BUILD_DIR)/$(EXECUTABLE_NAME)

# Bereinigen des Build-Verzeichnisses
clean:
	@echo "Cleaning up..."
ifeq ($(OS),Windows_NT)
	@if exist "$(BUILD_DIR)\*.o" del /Q "$(BUILD_DIR)\*.o"
	@if exist "$(BUILD_DIR)\$(EXECUTABLE_NAME).exe" del /Q "$(BUILD_DIR)\$(EXECUTABLE_NAME).exe"
	@if exist "$(TEST_BUILD_DIR)\*.o" del /Q "$(TEST_BUILD_DIR)\*.o"
	@if exist "$(TEST_BUILD_DIR)\$(TEST_EXECUTABLE_NAME).exe" del /Q "$(TEST_BUILD_DIR)\$(TEST_EXECUTABLE_NAME).exe"
	@if exist "$(BUILD_DIR)" rmdir /Q /S "$(BUILD_DIR)"
else
	@rm -f $(BUILD_DIR)/*.o
	@rm -f $(BUILD_DIR)/$(EXECUTABLE_NAME)
	@rm -f $(TEST_BUILD_DIR)/*.o
	@rm -f $(TEST_BUILD_DIR)/$(TEST_EXECUTABLE_NAME)
	@rm -rf $(BUILD_DIR)
endif
	@echo "Clean up finished."


# Test-Build: kompiliert die Tests ohne main.o
test: create $(TEST_OBJECTS) $(CXX_OBJECTS)
	$(CXX_COMPILER_CALL) $(TEST_OBJECTS) $(CXX_OBJECTS) $(LDFLAGS) -o $(TEST_BUILD_DIR)/$(TEST_EXECUTABLE_NAME)
	./$(TEST_BUILD_DIR)/$(TEST_EXECUTABLE_NAME)

##############
## PATTERNS ##
##############

# Kompiliert main.cpp ins Build-Verzeichnis
$(MAIN_OBJECT): main.cpp
	$(CXX_COMPILER_CALL) -c $< -o $@

# $@: steht für den Dateinamen des Targets
# $<: steht für den Namen der ersten Dependency
# Hier wird also für jede .cpp-Datei die Übersetzung in eine entsprechende
# .o-Datei durchgeführt, z.B.:
# g++ -c src/main.cpp -o build/main.o
$(BUILD_DIR)/%.o: $(SOURCE_DIR)/%.cpp
	$(CXX_COMPILER_CALL) -c $< -o $@

# Pattern rule für die Test-Objektdateien
$(TEST_BUILD_DIR)/%.o: $(TEST_DIR)/%.cpp
	$(CXX_COMPILER_CALL) -c $< -o $@

###########
## PHONY ##
###########

# "Phony"-Targets sind Targets, die keine Dateien repräsentieren
# make wird diese Targets auch immer ausführen, wenn sie aufgerufen werden
.PHONY: create build execute clean test run_tests
