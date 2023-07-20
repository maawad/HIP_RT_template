# FindHIPRT.cmake

message(STATUS "Searching for External Project: HIP RT")
# Find the HIPRT library

file(GLOB HIPRT_LIBRARY_DIR ${PROJECT_SOURCE_DIR}/externals/hiprt/hiprt/linux64/libhiprt*.so)

if(HIPRT_LIBRARY_DIR)
    get_filename_component(VERSIONED_HIPRT_LIBRARY_NAME ${HIPRT_LIBRARY_DIR} NAME)

    find_library(HIPRT_LIBRARY
        NAMES ${VERSIONED_HIPRT_LIBRARY_NAME}
        PATHS ${PROJECT_SOURCE_DIR}/externals/hiprt/hiprt/linux64
    )
endif()


# Check if HIPRT library is found
if(HIPRT_LIBRARY)
    # Set variables for the HIPRT library and include directory
    set(HIPRT_FOUND ${HIPRT_LIBRARY})
    set(HIPRT_INCLUDE_DIRS ${PROJECT_SOURCE_DIR}/externals/hiprt)
    set(HIPRT_LIBRARIES ${HIPRT_LIBRARY})
    
    # Report the HIPRT library and include directory to the user
    message(STATUS "Found HIPRT: ${HIPRT_LIBRARY}")
    message(STATUS "HIPRT Include Directory: ${HIPRT_INCLUDE_DIRS}")
else()
    # Print a message with the download link if HIPRT library is not found
    message(WARNING "HIP RT library not found. You can download it from: https://gpuopen.com/hiprt/#download")
endif()
