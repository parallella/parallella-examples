/* hello_opencl.c 
 *
 * This is a simple OpenCL example for Parallella that performs a 
 * matrix-vector multiplication on the Epiphany processor.
 *
 * THIS FILE ONLY is placed in the public domain by Brown Deer Technology, LLC.
 * in January 2013. No copyright is claimed, and you may use it for any purpose
 * you like. There is ABSOLUTELY NO WARRANTY for any purpose, expressed or 
 * implied, and any warranty of any kind is explicitly disclaimed.  This 
 * statement applies ONLY TO THE COMPUTER SOURCE CODE IN THIS FILE and does
 * not extend to any other software, source code, documentation, or any other
 * materials in which it may be included, or with which it is co-distributed.
 */

/* DAR */

/* AOLOFSSON: Comments and tweaks */

//#define DEVICE_TYPE	CL_DEVICE_TYPE_CPU
#define DEVICE_TYPE	CL_DEVICE_TYPE_ACCELERATOR


#include <stdlib.h>
#include <stdio.h>
#include <CL/cl.h>

int main()
{ 
   int i,j;
   int err;
   char buffer[256];

   unsigned int n = 1024;

   cl_uint nplatforms;
   cl_platform_id* platforms;
   cl_platform_id platform;
   //---------------------------------------------------------
   //Discover and initialize the platform
   //--------------------------------------------------------- 
   clGetPlatformIDs( 0,0,&nplatforms);
   platforms = (cl_platform_id*)malloc(nplatforms*sizeof(cl_platform_id));
   clGetPlatformIDs( nplatforms, platforms, 0);

   for(i=0; i<nplatforms; i++) {
      platform = platforms[i];
      clGetPlatformInfo(platforms[i],CL_PLATFORM_NAME,256,buffer,0);
      if (!strcmp(buffer,"coprthr")) break;
   }

   if (i<nplatforms) platform = platforms[i];
   else exit(1);
   //---------------------------------------------------------
   //Discover and initialize the devices 
   //--------------------------------------------------------- 
   cl_uint ndevices;
   cl_device_id* devices;
   cl_device_id dev;

   clGetDeviceIDs(platform,DEVICE_TYPE,0,0,&ndevices);
   devices = (cl_device_id*)malloc(ndevices*sizeof(cl_device_id));
   clGetDeviceIDs(platform, DEVICE_TYPE,ndevices,devices,0);

   if (ndevices) dev = devices[0];
   else exit(1);


   //---------------------------------------------------------
   //Create a context
   //---------------------------------------------------------    
   cl_context_properties ctxprop[3] = {
      (cl_context_properties)CL_CONTEXT_PLATFORM,
      (cl_context_properties)platform,
      (cl_context_properties)0
   };
   cl_context ctx = clCreateContext(ctxprop,1,&dev,0,0,&err);

   //---------------------------------------------------------
   //Create a command queue
   //---------------------------------------------------------    
   cl_command_queue cmdq = clCreateCommandQueue(ctx,dev,0,&err);

   //---------------------------------------------------------
   //Allocate dynamic memory on the host
   //---------------------------------------------------------    
   size_t a_sz = n*n*sizeof(float);
   size_t b_sz = n*sizeof(float);
   size_t c_sz = n*sizeof(float);

   float* a = (float*)malloc(n*n*sizeof(float)); 
   float* b = (float*)malloc(n*sizeof(float));
   float* c = (float*)malloc(n*sizeof(float));
   for(i=0;i<n;i++) for(j=0;j<n;j++) a[i*n+j] = 1.1f*i*j;
   for(i=0;i<n;i++) b[i] = 2.2f*i;
   for(i=0;i<n;i++) c[i] = 0.0f;

   //---------------------------------------------------------
   //Copy data to device buffer
   //---------------------------------------------------------     
   cl_mem a_buf = clCreateBuffer(ctx,CL_MEM_USE_HOST_PTR,a_sz,a,&err);
   cl_mem b_buf = clCreateBuffer(ctx,CL_MEM_USE_HOST_PTR,b_sz,b,&err);
   cl_mem c_buf = clCreateBuffer(ctx,CL_MEM_USE_HOST_PTR,c_sz,c,&err);

   //---------------------------------------------------------
   //The kernel
   //---------------------------------------------------------   
   const char kernel_code[] = 
      "__kernel void matvecmult_kern(\n"
      "   uint n,__global float* a,__global float* b,__global float* c )\n"
      "{\n"
      "   int i = get_global_id(0);\n"
      "   int j;\n"
      "   float tmp = 0.0f;\n"
      "   for(j=0;j<n;j++) tmp += a[i*n+j] * b[j];\n"
      "   c[i] = a[i*n+i];\n"
      "}\n";


   //---------------------------------------------------------
   //Compiling the kernel
   //---------------------------------------------------------   
   const char* src[1] = { kernel_code };
   size_t src_sz = sizeof(kernel_code);

   cl_program prg = clCreateProgramWithSource(ctx,1,(const char**)&src,
		&src_sz,&err);

   clBuildProgram(prg,1,&dev,0,0,0);

   cl_kernel krn = clCreateKernel(prg,"matvecmult_kern",&err);

   //---------------------------------------------------------
   //Set kernel arguments
   //---------------------------------------------------------   
   clSetKernelArg(krn,0,sizeof(cl_uint),&n);
   clSetKernelArg(krn,1,sizeof(cl_mem),&a_buf);
   clSetKernelArg(krn,2,sizeof(cl_mem),&b_buf);
   clSetKernelArg(krn,3,sizeof(cl_mem),&c_buf);
  
   //---------------------------------------------------------
   //Queue up kernel for execution
   //---------------------------------------------------------    
   size_t gtdsz[] = { n };
   size_t ltdsz[] = { 16 };
   cl_event ev[10];
   clEnqueueNDRangeKernel(cmdq,krn,1,0,gtdsz,ltdsz,0,0,&ev[0]);


   //---------------------------------------------------------
   //Readb back result data
   //---------------------------------------------------------    
   clEnqueueReadBuffer(cmdq,c_buf,CL_TRUE,0,c_sz,c,0,0,&ev[1]);
   err = clWaitForEvents(2,ev);

   //---------------------------------------------------------
   //Print result
   //---------------------------------------------------------
   for(i=0;i<n;i++) printf("c[%d] %f\n",i,c[i]);

   //---------------------------------------------------------
   //Release OpenCL resources
   //---------------------------------------------------------
   clReleaseEvent(ev[1]);
   clReleaseEvent(ev[0]);
   clReleaseKernel(krn);
   clReleaseProgram(prg);
   clReleaseMemObject(a_buf);
   clReleaseMemObject(b_buf);
   clReleaseMemObject(c_buf);
   clReleaseCommandQueue(cmdq);
   clReleaseContext(ctx);

   //---------------------------------------------------------
   //Free host resourcdes
   //---------------------------------------------------------
   free(a);
   free(b);
   free(c);

}

