cmake_minimum_required(VERSION 3.25)

set(CMAKE_VERBOSE_MAKEFILE ON)

project(devbox_test LANGUAGES CXX)

add_executable(app
    src/main.cpp
)

enable_testing()

add_test(NAME test COMMAND app)
