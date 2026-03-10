# Test harness Makefile
CXX := g++
CXXFLAGS := -std=c++17 -I.. -DTEST_HOST -Wall -g

SRCS := test_msp_bridge.cpp ../msp_bridge.cpp ../msp_loop.cpp
TARGET := test_msp

.PHONY: all clean test

all: $(TARGET)

$(TARGET): $(SRCS) ../msp_bridge.hpp ../msp_loop.hpp
	$(CXX) $(CXXFLAGS) -o $@ $(SRCS)

test: $(TARGET)
	./$(TARGET)

clean:
	rm -f $(TARGET)
