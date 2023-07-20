# FetchStb.cmake

include(FetchContent)

message(STATUS "Fetching External Project: STB")

FetchContent_Declare(
    stb
    GIT_REPOSITORY https://github.com/nothings/stb.git
    GIT_TAG        5736b15f7ea0ffb08dd38af21067c314d6a3aae9
)

FetchContent_GetProperties(stb)
if(NOT stb_POPULATED)
    FetchContent_Populate(stb)
    message(STATUS "Fetched STB source directory: ${stb_SOURCE_DIR}")
endif()

include_directories(${stb_SOURCE_DIR})
