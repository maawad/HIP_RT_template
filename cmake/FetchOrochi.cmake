include(FetchContent)


message(STATUS "Cloning External Project: Orochi")
get_filename_component(FC_BASE "../externals"
                REALPATH BASE_DIR "${CMAKE_BINARY_DIR}")
set(FETCHCONTENT_BASE_DIR ${FC_BASE})

FetchContent_Declare(
    orochi
    GIT_REPOSITORY https://github.com/GPUOpen-LibrariesAndSDKs/Orochi.git
    GIT_TAG        df8a401ebb1dbd1301a8281bd72acd449c6ae496
)

FetchContent_GetProperties(orochi)
FetchContent_Populate(orochi)
message(STATUS "Fetched Orochi source directory: ${orochi_SOURCE_DIR}")

include_directories(${orochi_SOURCE_DIR})

# Add the Orochi source files to your project
file(GLOB_RECURSE OROCHI_SOURCES "${orochi_SOURCE_DIR}/Orochi/*.cpp")
add_library(orochi OBJECT ${OROCHI_SOURCES})

