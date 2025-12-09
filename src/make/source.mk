CXX=g++
CXXFLAGS=-std=c++17 -Wall -MMD -MP
TARGET=make2maven

SRC=$(shell find src -name "*.cpp")
OBJ=$(patsubst src/%.cpp,build/%.o,$(SRC))
EXEC=$(TARGET)
DEPS=$(OBJ:.o=.d)

FORMAT_SOURCES=$(shell find src -name "*.cpp" -o -name "*.cc" -o -name "*.h" -o -name "*.hpp")

all: build # format

$(EXEC): $(OBJ)
	@mkdir -p $(@D)
	$(CXX) $(OBJ) -o $(EXEC)

build/%.o: src/%.cpp
	@mkdir -p $(@D)
	$(CXX) $(CXXFLAGS) -c $< -o $@

-include $(DEPS)

build: $(EXEC)

source-clean:
	@echo "Cleaning build files..."
	@find build -name "*.o" -type f -delete
	@find build -name "*.d" -type f -delete
	@rm -f $(EXEC)

format:
	@echo "Formatting source files..."
	@clang-format -i $(FORMAT_SOURCES)


.PHONY: all build source-clean format