include(FetchContent)


message(STATUS "Cloning External Project: Orochi")
get_filename_component(FC_BASE "../externals"
                REALPATH BASE_DIR "${CMAKE_BINARY_DIR}")
set(FETCHCONTENT_BASE_DIR ${FC_BASE})

FetchContent_Declare(
    orochi
    GIT_REPOSITORY https://github.com/GPUOpen-LibrariesAndSDKs/Orochi.git
    GIT_TAG df8a401ebb1dbd1301a8281bd72acd449c6ae496
)

FetchContent_GetProperties(orochi)
    FetchContent_Populate(orochi)
    message(STATUS "Fetched Orochi source directory: ${orochi_SOURCE_DIR}")

include_directories(
    ${orochi_SOURCE_DIR}
    ${orochi_SOURCE_DIR}/contrib/include
)

# Add the Orochi source files to your project
file(GLOB_RECURSE OROCHI_SOURCES "${orochi_SOURCE_DIR}/Orochi/*.cpp")
add_library(orochi OBJECT ${OROCHI_SOURCES})

# Add the cuew library to your project
set(CUEW_SOURCE_DIR ${orochi_SOURCE_DIR}/contrib/cuew/src)
set(CUEW_INCLUDE_DIR ${orochi_SOURCE_DIR}/contrib/cuew/include)
add_library(cuew OBJECT ${CUEW_SOURCE_DIR}/cuew.cpp)
target_include_directories(cuew PRIVATE ${CUEW_INCLUDE_DIR})


# Add the cuew library to your project
set(HIPEW_SOURCE_DIR ${orochi_SOURCE_DIR}/contrib/hipew/src)
set(HIPEW_INCLUDE_DIR ${orochi_SOURCE_DIR}/contrib/hipew/include)
add_library(hipew OBJECT ${HIPEW_SOURCE_DIR}/hipew.cpp)
target_include_directories(hipew PRIVATE ${HIPEW_INCLUDE_DIR})



