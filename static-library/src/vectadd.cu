#include "vectadd.cuh"

namespace vectadd {

__global__
void vectAddEqCUDA(int count, float *vec0, const float *vec1);

}  // namespace vectadd

namespace vectadd {

void vectAdd(int count, const float *vec0, const float *vec1, float *added) {
  cudaDeviceProp deviceProp;
  cudaGetDeviceProperties(&deviceProp, 0);

  const int blockSize = deviceProp.maxThreadsPerBlock;
  const int blockCount = (count - 1) / blockSize + 1;

  float *d_vec0;
  float *d_vec1;

  cudaMalloc(&d_vec0, count * sizeof(float));
  cudaMalloc(&d_vec1, count * sizeof(float));

  cudaMemcpy(d_vec0, vec0, count * sizeof(float), cudaMemcpyHostToDevice);
  cudaMemcpy(d_vec1, vec1, count * sizeof(float), cudaMemcpyHostToDevice);

  vectAddEqCUDA<<<blockCount, blockSize>>>(count, d_vec0, d_vec1);

  cudaMemcpy(added, d_vec0, count * sizeof(float), cudaMemcpyDeviceToHost);

  cudaFree(d_vec0);
  cudaFree(d_vec1);
}

__global__
void vectAddEqCUDA(int count, float *vec0, const float *vec1)
{
  int index = blockIdx.x * blockDim.x + threadIdx.x;
  int stride = blockDim.x * gridDim.x;

  for(int i = index; i < count; i += stride) {
    vec0[i] += vec1[i];
  }
}

}  // namespace vectadd
