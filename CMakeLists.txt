cmake_minimum_required(VERSION 3.10)
project(WizardMirror CXX)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_FLAGS "-Wall -Wextra -O2")

# Add source files
file(GLOB_RECURSE SOURCES "src/*.cpp")

include_directories(include)

# Create the executable
add_executable(wizardmirror ${SOURCES})

message(STATUS "Sources found: ${SOURCES}")

# Include header files
target_include_directories(wizardmirror PRIVATE include)
find_package(SDL3 REQUIRED)
find_package(SDL3_ttf REQUIRED)
target_link_libraries(wizardmirror PRIVATE SDL3::SDL3)
target_link_libraries(wizardmirror PRIVATE SDL3_ttf::SDL3_ttf)