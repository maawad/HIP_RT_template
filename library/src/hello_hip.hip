#include <iostream>

#include <hello_hip.hxx>
#include "helpers.hxx"

#include <hip/hip_runtime.h>

#include <thrust/device_vector.h>
#include <thrust/host_vector.h>

#include <hiprt/hiprt.h>

__global__ void hello_hip(int* foo, int* bar, int* baz) {
  printf("Hello World!\n");
  baz[0] = bar[0] + foo[0];
}

void launch_hello_hip() {
  std::cout << "Launching hello_hip!" << std::endl;

  thrust::device_vector<int> foo(1, 1);
  thrust::device_vector<int> bar(1, 2);
  thrust::device_vector<int> baz(1, 0);

  hello_hip<<<1, 1>>>(foo.data().get(), bar.data().get(), baz.data().get());

  hip_try(hipDeviceSynchronize());

  std::cout << "Launched hello_hip!" << std::endl;

  thrust::host_vector<int> h_baz(baz);
  std::cout << h_baz[0] << std::endl;
}

void set_device(int device_id) {
  hip_device dev(device_id);
  dev.print_device_properties();
}