#include <iostream>

#include <hello_hip.hxx>
#include "helpers.hxx"

#include <hip/hip_runtime.h>

#include <thrust/device_vector.h>
#include <thrust/host_vector.h>

#include <hiprt/hiprt.h>
#include <Orochi/Orochi.h>

#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"

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

void launchKernel(oroFunction func,
                  int nx,
                  int ny,
                  int bx,
                  int by,
                  void** args) {
  hiprtInt3 nb;
  nb.x = (nx + bx - 1) / bx;
  nb.y = (ny + by - 1) / by;
  oro_try(oroModuleLaunchKernel(func, nb.x, nb.y, 1, bx, by, 1, 0, 0, args, 0));
}

void launchKernel(oroFunction func, int nx, int ny, void** args) {
  launchKernel(func, nx, ny, 8, 8, args);
}

void writeImage(const std::string& path, int w, int h, u8* pixels) {
  std::vector<u8> image(w * h * 4);
  oro_try(oroMemcpyDtoH(image.data(), (oroDeviceptr)pixels, w * h * 4));
  stbi_write_png(path.c_str(), w, h, 4, image.data(), w * 4);
  std::cout << "image written at " << path.c_str() << std::endl;
}

void init(int deviceIndex,
          hiprtContextCreationInput& m_ctxtInput,
          oroDevice& m_oroDevice,
          oroCtx& m_oroCtx,
          hiprtInt2& m_res) {
  m_res = make_hiprtInt2(512, 512);

  oro_try((oroError)oroInitialize((oroApi)(ORO_API_HIP | ORO_API_CUDA), 0));

  oro_try(oroInit(0));
  oro_try(oroDeviceGet(&m_oroDevice, deviceIndex));
  oro_try(oroCtxCreate(&m_oroCtx, 0, m_oroDevice));

  oroDeviceProp props;
  oro_try(oroGetDeviceProperties(&props, m_oroDevice));

  std::cout << "hiprt ver." << HIPRT_VERSION_STR << std::endl;
  std::cout << "Executing on '" << props.name << "'" << std::endl;
  if (std::string(props.name).find("NVIDIA") != std::string::npos)
    m_ctxtInput.deviceType = hiprtDeviceNVIDIA;
  else
    m_ctxtInput.deviceType = hiprtDeviceAMD;

  m_ctxtInput.ctxt = oroGetRawCtx(m_oroCtx);
  m_ctxtInput.device = oroGetRawDevice(m_oroDevice);
}

void buildTraceKernelFromBitcode(hiprtContext ctxt,
                                 const char* functionName,
                                 oroFunction& functionOut,
                                 int numGeomTypes = 0,
                                 int numRayTypes = 1) {
  size_t binarySize = 0;
  std::vector<const char*> options;
  std::vector<std::string> includeNamesData;

  std::vector<std::string> headersData(includeNamesData.size());
  std::vector<const char*> headers;
  std::vector<const char*> includeNames;

  const bool isAmd = oroGetCurAPI(0) == ORO_API_HIP;
  if (isAmd) {
    options.push_back("-fgpu-rdc");
    options.push_back("-Xclang");
    options.push_back("-mno-constructor-aliases");
  } else {
    options.push_back("--device-c");
    options.push_back("-arch=compute_60");
  }
  options.push_back("-std=c++17");

  const std::string sourceCode = R"(
#include <hiprt/hiprt_device.h>
#include <hiprt/hiprt_vec.h>   

extern "C" __global__ void GeomIntersectionKernel(hiprtGeometry geom, u8* pixels, int2 res)
{
    const int x = blockIdx.x * blockDim.x + threadIdx.x;
    const int y = blockIdx.y * blockDim.y + threadIdx.y;

    float3 o = { x / (float)res.x, y / (float)res.y, -1.0f };
    float3 d = { 0.0f, 0.0f, 1.0f };

    hiprtRay ray;
    ray.origin = o;
    ray.direction = d;

    hiprtGeomTraversalClosest tr(geom, ray);
    hiprtHit hit = tr.getNextHit();

    int pixelIndex = x + y * res.x;
    pixels[pixelIndex * 4 + 0] = hit.hasHit() ? ((float)x / res.x) * 255 : 0;
    pixels[pixelIndex * 4 + 1] = hit.hasHit() ? ((float)y / res.y) * 255 : 0;
    pixels[pixelIndex * 4 + 2] = 0;
    pixels[pixelIndex * 4 + 3] = 255;
}
)";

  uint32_t num_functions = 1;
  hiprtApiFunction function;
  hiprtApiModule module;
  std::string module_name = "test";
  hiprt_try(hiprtBuildTraceKernels(
      ctxt, num_functions, &functionName, module_name.data(), sourceCode.data(),
      0, nullptr, nullptr, options.size(), options.data(), numGeomTypes,
      numRayTypes, nullptr, &function, &module));

  functionOut = *(oroFunction*)&function;
}
void run() {
  std::cout << "run()" << std::endl;
  hiprtContextCreationInput m_ctxtInput;
  oroCtx m_oroCtx;
  oroDevice m_oroDevice;
  hiprtInt2 m_res;

  init(0, m_ctxtInput, m_oroDevice, m_oroCtx, m_res);

  std::cout << "declare" << std::endl;
  hiprtContext ctxt;
  hiprt_try(hiprtCreateContext(HIPRT_API_VERSION, m_ctxtInput, &ctxt));
  std::cout << "hiprtCreateContext()" << std::endl;

  hiprtTriangleMeshPrimitive mesh;
  mesh.triangleCount = 2;
  mesh.triangleStride = sizeof(hiprtInt3);
  int triangleIndices[] = {0, 1, 2, 3, 4, 5};
  std::cout << "mesh()" << std::endl;

  oro_try(oroMalloc((oroDeviceptr*)&mesh.triangleIndices,
                    mesh.triangleCount * sizeof(hiprtInt3)));
  std::cout << "oroMalloc()" << std::endl;
  oro_try(oroMemcpyHtoD((oroDeviceptr)mesh.triangleIndices, triangleIndices,
                        mesh.triangleCount * sizeof(hiprtInt3)));
  std::cout << "oroMemcpyHtoD()" << std::endl;

  mesh.vertexCount = 6;
  mesh.vertexStride = sizeof(hiprtFloat3);
  hiprtFloat3 vertices[] = {{0.0f, 0.0f, 0.0f}, {1.0f, 0.0f, 0.0f},
                            {0.5f, 1.0f, 0.0f}, {0.0f, 0.0f, 1.0f},
                            {1.0f, 0.0f, 1.0f}, {0.5f, 1.0f, 1.0f}};
  oro_try(oroMalloc((oroDeviceptr*)&mesh.vertices,
                    mesh.vertexCount * sizeof(hiprtFloat3)));
  oro_try(oroMemcpyHtoD((oroDeviceptr)mesh.vertices, vertices,
                        mesh.vertexCount * sizeof(hiprtFloat3)));

  std::cout << "Building Geometry" << std::endl;
  hiprtGeometryBuildInput geomInput;
  geomInput.type = hiprtPrimitiveTypeTriangleMesh;
  geomInput.triangleMesh.primitive = &mesh;

  size_t geomTempSize;
  hiprtDevicePtr geomTemp;
  hiprtBuildOptions options;
  options.buildFlags = hiprtBuildFlagBitPreferFastBuild;
  hiprt_try(hiprtGetGeometryBuildTemporaryBufferSize(ctxt, &geomInput, &options,
                                                     &geomTempSize));
  oro_try(oroMalloc((oroDeviceptr*)&geomTemp, geomTempSize));

  hiprtGeometry geom;
  hiprt_try(hiprtCreateGeometry(ctxt, &geomInput, &options, &geom));
  hiprt_try(hiprtBuildGeometry(ctxt, hiprtBuildOperationBuild, &geomInput,
                               &options, geomTemp, 0, geom));

  oroFunction func;
  buildTraceKernelFromBitcode(ctxt, "GeomIntersectionKernel", func);

  u8* pixels;
  oro_try(oroMalloc((oroDeviceptr*)&pixels, m_res.x * m_res.y * 4));

  void* args[] = {&geom, &pixels, &m_res};
  launchKernel(func, m_res.x, m_res.y, args);
  // writeImage("01_geom_intersection.png", m_res.x, m_res.y, pixels);

  oro_try(oroFree((oroDeviceptr)mesh.triangleIndices));
  oro_try(oroFree((oroDeviceptr)mesh.vertices));
  oro_try(oroFree((oroDeviceptr)geomTemp));
  oro_try(oroFree((oroDeviceptr)pixels));

  hiprt_try(hiprtDestroyGeometry(ctxt, geom));
  hiprt_try(hiprtDestroyContext(ctxt));
}
void set_device(int device_id) {
  hip_device dev(device_id);
  dev.print_device_properties();
}