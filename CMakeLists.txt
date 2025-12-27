# CMake configuration for AndroDev Assistant
# Professional build system for MinGW-w64 x86_64
#
cmake_minimum_required(VERSION 3.20 FATAL_ERROR)

# Set CMake module path
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

# Project definition
project(AndroDevAssistant VERSION 1.0.0 LANGUAGES CXX)

# Set project properties
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# Enable ccache for faster builds
find_program(CCACHE_EXECUTABLE ccache)
if(CCACHE_EXECUTABLE)
    message(STATUS "Found ccache: ${CCACHE_EXECUTABLE}")
    set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE ${CCACHE_EXECUTABLE})
    set_property(GLOBAL PROPERTY RULE_LAUNCH_LINK ${CCACHE_EXECUTABLE})
endif()

# Enable parallel builds
set(CMAKE_BUILD_PARALLEL_LEVEL "$ENV{NUMBER_OF_PROCESSORS}")
set_property(GLOBAL PROPERTY JOB_POOLS compile_job_pool=${CMAKE_BUILD_PARALLEL_LEVEL} link_job_pool=4)
set_property(GLOBAL PROPERTY MAKEFLAGS -j${CMAKE_BUILD_PARALLEL_LEVEL})

# Enable output of compile commands for IDEs and static analysis
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Include helper modules
include(CompilerOptions)
include(Dependencies)
include(StaticAnalysis)
include(Testing)
include(Install)
include(Version)

# Add subdirectories
add_subdirectory(AndroDev_Assistant)

# Add tests directory if it exists
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/tests AND BUILD_TESTING)
    add_subdirectory(tests)
endif()

# Add examples directory if it exists
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/examples)
    add_subdirectory(examples)
endif()

# Add custom targets for convenience
add_custom_target(clean-all
    COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_BINARY_DIR}
    COMMENT "Cleaning all build files"
    VERBATIM
)

add_custom_target(build-all
    COMMAND ${CMAKE_COMMAND} --build ${CMAKE_BINARY_DIR} --config Debug
    COMMAND ${CMAKE_COMMAND} --build ${CMAKE_BINARY_DIR} --config Release
    COMMAND ${CMAKE_COMMAND} --build ${CMAKE_BINARY_DIR} --config RelWithDebInfo
    COMMAND ${CMAKE_COMMAND} --build ${CMAKE_BINARY_DIR} --config MinSizeRel
    COMMENT "Building all configurations"
    VERBATIM
)
