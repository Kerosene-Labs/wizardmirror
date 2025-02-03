cmake_minimum_required(VERSION 3.10)
project(WizardMirror CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_FLAGS "-Wall -Wextra -O2")

# Add source files
file(GLOB SOURCES "src/*.cpp")

# Create the executable
add_executable(app ${SOURCES})

message(STATUS "Sources found: ${SOURCES}")

# Include header files
target_include_directories(app PRIVATE include)

find_package(SDL3 REQUIRED)
find_package(SDL3_ttf REQUIRED)
target_link_libraries(app PRIVATE SDL3::SDL3)
target_link_libraries(app PRIVATE SDL3_ttf::SDL3_ttf)