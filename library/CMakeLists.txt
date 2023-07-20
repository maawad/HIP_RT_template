####################################################
################# TARGET SOURCES ###################
####################################################
set(HELLO_HIP_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/src)
include(src/CMakeLists.txt)


include(${PROJECT_SOURCE_DIR}/cmake/FetchOrochi.cmake)
include(${PROJECT_SOURCE_DIR}/cmake/FindHIPRT.cmake)

add_library(hello_hip ${HELLO_HIP_SOURCE})

####################################################
############### SET TARGET PROPERTIES ##############
####################################################
set_target_properties(hello_hip 
  PROPERTIES
    CXX_STANDARD 17
    CXX_STANDARD_REQUIRED ON
    CXX_EXTENSIONS OFF
    HIP_STANDARD 17
    HIP_STANDARD_REQUIRED ON
    HIP_EXTENSIONS OFF
    HIP_ARCHITECTURES ${CMAKE_HIP_ARCHITECTURES}
)

####################################################
############ TARGET COMPILER DEFINITIONS ###########
####################################################
target_compile_definitions(hello_hip
  PRIVATE
    __HIP_PLATFORM_AMD__
)

message(STATUS "hello_hip HIP Architecture: ${CMAKE_HIP_ARCHITECTURES}")

####################################################
############ TARGET COMPILE FEATURES ###############
####################################################
target_compile_features(hello_hip PRIVATE cxx_std_17)

####################################################
############ TARGET INCLUDE DIRECTORIES ############
####################################################
set(HELLO_HIP_INCLUDE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/include)

target_include_directories(hello_hip
  PUBLIC ${HELLO_HIP_INCLUDE_DIR}
  SYSTEM PRIVATE /opt/rocm/include
  SYSTEM PRIVATE /opt/rocm/hip/include/
  SYSTEM PRIVATE ${HIPRT_INCLUDE_DIRS}
)

####################################################
########## TARGET LINK LIBRARIES/DIRS ##############
####################################################
target_link_directories(hello_hip 
  PRIVATE /opt/rocm/lib
)

target_link_libraries(hello_hip
  PRIVATE ${HIPRT_LIBRARIES}
  # PRIVATE rocrand
  # PRIVATE rocsparse
)

####################################################
############ TARGET COMPILE OPTIONS ################
####################################################
target_compile_options(hello_hip PUBLIC 
  $<$<COMPILE_LANGUAGE:CXX>:${CXX_FLAGS}>
  $<$<COMPILE_LANGUAGE:HIP>:${HIP_FLAGS}>
)
