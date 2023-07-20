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

FetchContent_MakeAvailable(orochi)
# get_target_property(orochi_type orochi TYPE)
# message(STATUS "Orochi target type: ${orochi_type}")


# add_library(orochi::orochi ALIAS orochi)

