# HIP Template [![ubuntu-focal](https://github.com/neoblizz/HIP_template/actions/workflows/ubuntu-focal.yml/badge.svg)](https://github.com/neoblizz/HIP_template/actions/workflows/ubuntu-focal.yml) [![ubuntu-jammy](https://github.com/neoblizz/HIP_template/actions/workflows/ubuntu-jammy.yml/badge.svg)](https://github.com/neoblizz/HIP_template/actions/workflows/ubuntu-jammy.yml)

A template inspired by [@Ahdhn](https://github.com/Ahdhn)'s [CUDATemplate](https://github.com/Ahdhn/CUDATemplate) to start a new HIP project using CMake on Linux. Note when HIP/ROCm is publicly made available on Windows and Windows Subsystem for Linux (WSL), I will update this template to reflect the support for that as well. This template provides a simple, easy-to-modify CMake file, with GitHub Actions pre-configured to build check-ins and test if the compilation succeeds.

## Installing Requirements
- `cmake` required minimum version 2.24.x:
```bash
python3 -m pip install 'cmake==3.24.0'
```
- ROCm/HIP recommended version 5.4.x or above. Installation instructions vary, please refer to the [How to Install ROCm](https://docs.amd.com/bundle/ROCm-Installation-Guide-v5.4.2/page/How_to_Install_ROCm.html). The following is an example of how to install ROCm 5.4.x, HIP and some useful libraries on an Ubuntu 22.04 system using `apt-get`:
```bash
sudo apt-get update
curl -fsSL https://repo.radeon.com/rocm/rocm.gpg.key | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/rocm-keyring.gpg
echo 'deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/rocm-keyring.gpg] https://repo.radeon.com/rocm/apt/5.4 jammy main' | sudo tee /etc/apt/sources.list.d/rocm.list
echo -e 'Package: *\nPin: release o=repo.radeon.com\nPin-Priority: 600' | sudo tee /etc/apt/preferences.d/rocm-pin-600
```

```
sudo apt-get update
sudo apt-get install -y rocm-dev hip-dev rocm-libs
```

## Configure Environment
- Export `$PATH` for ROCm and HIP libraries by adding the following to the end of your `~\.bashrc` or `~\.bash_profile` file in your home directory, and then perform `source ~\.bashrc`. This is also illustrated in the installation of ROCm/HIP guide.
```bash
# Export ROCM/HIP Paths
export ROCM_PATH=/opt/rocm          # Must use this variable name
export HIP_PATH=/opt/rocm/hip       # Must use this variable name
export PATH=$HOME/.local/bin:${ROCM_PATH}/bin:${HIP_PATH}/bin:$PATH
export LD_LIBRARY_PATH=${ROCM_PATH}:${ROCM_PATH}/lib:${HIP_PATH}/lib:$LD_LIBRARY_PATH
```

## Getting Started

Assuming you have the requirements installed and configured, simply fetch the project and build using CMake to get started!

```bash
git clone https://github.com/neoblizz/HIP_template.git
cd HIP_template
mkdir build && cd build
cmake ..
make -j$(nproc)
```

This will generate the example executable in `bin` directory under `build`, which can be executed like so:
```
./bin/hello
```

## Directory Structure
This template follows a standard C++ library's directory structure. Important directories are `library/src` for source files, `library/include` for library includes, `examples` for a simple "hello world" example that uses the library, and `unittests` for GoogleTests based testing framework. You must download and extract the `hiprt` libarary and place it inside the `hiprt` directory as shown below. You can find the HIP Ray Tracing library [here](https://gpuopen.com/hiprt/#download).
```
.
├── CMakeLists.txt
├── README.md
├── cmake
├── examples
├── externals
    ├── hiprt  # Contents of this folder is NOT INCLUDED IN THIS REPO
        ├── win
        ├── buildID_linux.txt
        ├── buildID_win.txt
        ├── linux64
        ├── README.md
        ├── hiprt_common.h
        ├── hiprt_device.h
        ├── hiprtew.h
        ├── hiprt.h
        ├── hiprt_types.h
        ├── hiprt_vec.h
├── library
│   ├── include
│   └── src
├── scripts
│   └── format.sh
└── unittests
```

## Trouble shooting



You might need to install `libstdc++` if you see an error like this:
```terminal
-- Defaulting to Release build type
-- The CXX compiler identification is GNU 11.3.0
-- The C compiler identification is GNU 11.3.0
-- The HIP compiler identification is unknown
-- Detecting CXX compiler ABI info
-- Detecting CXX compiler ABI info - done
-- Check for working CXX compiler: /usr/bin/c++ - skipped
-- Detecting CXX compile features
-- Detecting CXX compile features - done
-- Detecting C compiler ABI info
-- Detecting C compiler ABI info - done
-- Check for working C compiler: /usr/bin/cc - skipped
-- Detecting C compile features
-- Detecting C compile features - done
-- Detecting HIP compiler ABI info
-- Detecting HIP compiler ABI info - failed
-- Check for working HIP compiler: /opt/rocm-5.6.0/llvm/bin/clang++
-- Check for working HIP compiler: /opt/rocm-5.6.0/llvm/bin/clang++ - broken
CMake Error at /opt/cmake/share/cmake-3.27/Modules/CMakeTestHIPCompiler.cmake:63 (message):
  The HIP compiler

    "/opt/rocm-5.6.0/llvm/bin/clang++"

  is not able to compile a simple test program.

  It fails with the following output:

    Change Dir: 'HIP_RT_template/build/CMakeFiles/CMakeScratch/TryCompile-gpqA6b'
    
    Run Build Command(s): /opt/cmake/bin/cmake -E env VERBOSE=1 /usr/bin/gmake -f Makefile cmTC_833af/fast
    /usr/bin/gmake  -f CMakeFiles/cmTC_833af.dir/build.make CMakeFiles/cmTC_833af.dir/build
    gmake[1]: Entering directory 'HIP_RT_template/build/CMakeFiles/CMakeScratch/TryCompile-gpqA6b'
    Building HIP object CMakeFiles/cmTC_833af.dir/testHIPCompiler.hip.o
    /opt/rocm-5.6.0/llvm/bin/clang++ -D__HIP_ROCclr__=1 -I/opt/rocm-5.6.0/include --cuda-host-only  --offload-arch=gfx1100 -mllvm -amdgpu-early-inline-all=true -mllvm -amdgpu-function-calls=false -o CMakeFiles/cmTC_833af.dir/testHIPCompiler.hip.o  -c HIP_RT_template/build/CMakeFiles/CMakeScratch/TryCompile-gpqA6b/testHIPCompiler.hip
    In file included from <built-in>:1:
    In file included from /opt/rocm-5.6.0/llvm/lib/clang/16.0.0/include/__clang_hip_runtime_wrapper.h:50:
    /opt/rocm-5.6.0/llvm/lib/clang/16.0.0/include/cuda_wrappers/cmath:27:15: fatal error: 'cmath' file not found
    #include_next <cmath>
                  ^~~~~~~
    1 error generated when compiling for host.
    gmake[1]: *** [CMakeFiles/cmTC_833af.dir/build.make:78: CMakeFiles/cmTC_833af.dir/testHIPCompiler.hip.o] Error 1
    gmake[1]: Leaving directory 'HIP_RT_template/build/CMakeFiles/CMakeScratch/TryCompile-gpqA6b'
    gmake: *** [Makefile:127: cmTC_833af/fast] Error 2
    
    

  

  CMake will not be able to correctly generate this project.
Call Stack (most recent call first):
  CMakeLists.txt:27 (project)


-- Configuring incomplete, errors occurred!
```


You can install it using the following command:
```bash
sudo apt install libstdc++-12-dev
```


## License & Maintainer
- This work is **Unlicensed**. A license with no conditions whatsoever which dedicates works to the public domain. Unlicensed works, modifications, and larger works may be distributed under different terms and without source code.
- Maintained by [Muhammad Osama](https://github.com/neoblizz) \<muhammad.osama@amd.com\>


