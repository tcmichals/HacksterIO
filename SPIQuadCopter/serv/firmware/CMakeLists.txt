# CMake build for SERV firmware (C++)
cmake_minimum_required(VERSION 3.10)
project(serv_firmware CXX)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_executable(serv_firmware
    main.cpp
    msp_bridge.cpp
)

target_include_directories(serv_firmware PRIVATE .)
