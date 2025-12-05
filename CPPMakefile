CXX=g++
CXXFLAGS=-std=c++17 -Wall -MMD -MP
TARGET=make2maven

SRC=$(shell find src -name "*.cpp")
OBJ=$(patsubst src/%.cpp,build/%.o,$(SRC))
EXEC=$(TARGET)
DEPS=$(OBJ:.o=.d)

all: build

$(EXEC): $(OBJ)
	@mkdir -p $(@D)
	$(CXX) $(OBJ) -o $(EXEC)

build/%.o: src/%.cpp
	@mkdir -p $(@D)
	$(CXX) $(CXXFLAGS) -c $< -o $@

-include $(DEPS)

build: $(EXEC)

clean:
	rm -rf build

.PHONY: all build clean