# Vector addition with R via OpenCL

This example demonstrates how to do a simple parallel vector addition from within the R programming language.

## Implementation

The official Linaro Nano distribution is assumed.

Uses R-3, the Rcpp and ROpenCL packages, and the COPRTHR and Epiphany SDKs.

The compute kernel is entered via the R prompt.

## Building

Ensure that your environment is set up for the COPRTHR SDK. If it is not and you are using the Bash shell:

```bash
export PATH="/usr/local/browndeer/bin:$PATH"
export LD_LIBRARY_PATH="/usr/local/browndeer/lib:$LD_LIBRARY_PATH"
```

Install package dependencies.

```bash
$ sudo apt-get install bison gfortran libreadline-gplv2-dev
```

Download and extract the R-3.0.3 sources.

```bash
$ wget http://www.stats.bris.ac.uk/R/src/base/R-3/R-3.0.3.tar.gz
$ tar xzvf R-3.0.3.tar.gz
$ cd R*
```

Configure for a headless (no X11 display output) R.

```bash
$ ./configure --with-x=no
```

If configure fails resolve any missing dependencies.

Build and install.

```bash
$ make
$ sudo make install
```

Start R, install the Rcpp package and then quit back to the shell.

```bash
$ R
```

```R
R> install.packages("Rcpp")
R> quit()
```

Download and extract the ROpenCL package sources.

```bash
$ wget http://repos.openanalytics.eu/src/contrib/ROpenCL_0.1-1.tar.gz
$ tar xzvf ROpenCL_0.1-1.tar.gz
```

Apply the Parallella patch.

```bash
$ patch -p0 <parallella-ROpenCL_0.1-1.patch
```

Check to see if the file `/usr/local/browndeer/include/CL/opencl.h` exists. If it does not, grab it from the [COPRTHR SDK GitHub repo](https://github.com/browndeer/coprthr/blob/current/include/CL/opencl.h).

Install ROpenCL.

```bash
$ sudo R CMD INSTALL ROpenCL
```

Test that we can now access the Epiphany from R.

```bash
$ sudo su
$ R
```

```R
> p <- getPlatformIDs()
coprthr-1.6.0 (Freewill)
> d <- getDeviceIDs(p[[1]])
> d
[[1]]
<pointer: 0x224548>

[[2]]
<pointer: 0x5bdea0>
```

## Usage

We can now run OpenCL code on the Epiphany. The code above returns two devices. The first ( d[[1]] ) is always the ARM host, the second ( d[[2]] ) is always the Epiphany. Make sure that you deploy your kernel to the second device.
The vector addition example that follows was provided by [Willem Ligtenberg](http://openanalytics.eu), author of the ROpenCL package.

To create a kernel paste the following at the R prompt.

```R
require(ROpenCL)   
p <- getPlatformIDs()
d <- getDeviceIDs(p[[1]]) 
context <- createContext(d[[2]])               # d[[2]] is the Epiphany!
queue <- createCommandQueue(context, d[[2]])   # d[[2]] is the Epiphany!
   
a <- seq(256)/10
b <- seq(256)
out <- rep(0.0, length(a))
 
localWorkSize = 16
globalWorkSize = ceiling(length(a)/localWorkSize)*localWorkSize

inputBuf1 <- createBuffer(context, "CL_MEM_READ_ONLY", globalWorkSize, a)
inputBuf2 <- createBuffer(context, "CL_MEM_READ_ONLY", globalWorkSize, b)
outputBuf1 <- createBufferFloatVector(context, "CL_MEM_WRITE_ONLY", globalWorkSize)

kernel <- "__kernel void VectorAdd(__global const float* a, __global const int* b, __global float* c, int iNumElements)
{
    // get index into global data array
    int iGID = get_global_id(0);

    // bound check (equivalent to the limit on a 'for' loop for standard/serial C code
    if (iGID >= iNumElements)
    {   
        return; 
    }
    // add the vector elements
    c[iGID] = a[iGID] + b[iGID];
}"

kernel <- createProgram(context, kernel, "VectorAdd", inputBuf1, inputBuf2, outputBuf1, length(out))
```

Paste the following at the R prompt to input two vectors to the device and launch the compute kernel.

```R
enqueueWriteBuffer(queue, inputBuf1, globalWorkSize, a)
enqueueWriteBuffer(queue, inputBuf2, globalWorkSize, b)
enqueueNDRangeKernel(queue, kernel, globalWorkSize, localWorkSize)
```

Collect the result and print it out.

```R
result <- enqueueReadBuffer(queue, outputBuf1, globalWorkSize, out)
result
```

To verify correctness, compare the result to a+b.

```R
a+b
```

## License

GPL v3

## Authors

Original how-to posts ([installing R](http://forums.parallella.org/viewtopic.php?f=39&t=367), [accessing Epiphany pt.1](http://forums.parallella.org/viewtopic.php?f=39&t=368), [accessing Epiphany pt.2](http://forums.parallella.org/viewtopic.php?f=39&t=373)) and ROpenCL patch contributed by Soren Wilkening a.ka. Censix.

R OpenCL kernel copyright Willem Ligtenberg.

Added to the parallella-examples repository by Andrew Back.
