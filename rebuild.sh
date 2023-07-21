#!/bin/bash

targets=("all")
build="Debug"
# build="Release"

cmake -DCMAKE_BUILD_TYPE=${build} -B build --fresh
cmake --build build --target "${targets[@]}" -- -j$(nproc) 