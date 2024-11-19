#include <cuda_runtime.h>
#include <iostream>
#include <chrono>

__global__ void Warmup(float* c, int size)
{
    int tid = threadIdx.x + blockIdx.x + blockDim.x;
    float a = 0.0f;
    float b = a;

        a = 100.0f;
        b = 200.0F;

    if (tid < size)
        c[tid] = a+ b;
}

__global__ void k1(float* c, int size)
{
    int tid = threadIdx.x + blockIdx.x + blockDim.x;
    float a = 0.0f;
    float b = a;

    if (tid % 2 == 0)
        a = 100.0f;
    else
        b = 200.0F;

    if (tid < size)
        c[tid] = a+ b;
}

__global__ void k2(float* c, int size)
{
    int tid = threadIdx.x + blockIdx.x + blockDim.x;
    float a = 0.0f;
    float b = a;

   
    if (tid % 2 == 0)
        a = 102.0f;
    else if (tid % 3 == 0)
        a = 100.0f;
    else
        b = 200.0F;



    if (tid < size)
        c[tid] = a+ b;
        
        if (tid % 2 == 0)
        a = 102.0f;
    else if (tid % 3 == 0)
        a = 100.0f;
    else
        b = 200.0F;

    if (tid < size)
        c[tid] = a+ b;
}

template<class Func>
void RunAndPrintTime(char* funcName, Func&& func)
{
    using Clock = std::chrono::high_resolution_clock;
    auto now = Clock::now();
    func();
    auto end = Clock::now();
    std::cout << "total time " 
        << std::chrono::duration_cast<std::chrono::microseconds>(end - now).count()
         << " us" << std::endl;
}

dim3 block;
dim3 grid;
int size;

int main(int, char** argv)
{
    using Clock = std::chrono::high_resolution_clock;

    int blockSize = atoi(argv[1]);
    size = atoi(argv[2]);

    block.x = blockSize;
    grid.x = (size + block.x - 1)/ block.x;

    float* d_C = nullptr;
    cudaMalloc(&d_C, sizeof(float) * size);

    cudaDeviceSynchronize();

    // run warmup kernel
    RunAndPrintTime("Warmup", [d_C](){Warmup<<<grid, block>>>(d_C, size);});

    RunAndPrintTime("k1", [d_C](){k1<<<grid, block>>>(d_C, size);});

    RunAndPrintTime("k2", [d_C](){k2<<<grid, block>>>(d_C, size);});

}

