# Pi calculation

This program is a simple pi=3.14159... calculation which utilizes multiple threads
on the host (Zynq). Each thread offloads a seperate kernel to the default devive
(Epiphany). The ```OMP_DEFAULT_DEVICE``` environmental variable may be used to offload
the kernels to the Zynq cores instead.

# Building

You need to have [OMPi v2.0.0](http://paragroup.cse.uoi.gr/wpsite/software/ompi) or later installed.
In order to build this application, simply execute:

```Shell
ompicc pi.c
```

# Usage

On `esdk.2015.1`, run the application executing the following command:

```Shell
./a.out
```

For older e-SDK versions:

```Shell
./run.sh
```

To target the Zynq or the Epiphany set the value of ```OMP_DEFAULT_DEVICE``` environmental variable
to ```0``` or ```1``` correspondingly.

For example:

```Shell
export OMP_DEFAULT_DEVICE="0"
export OMP_DEFAULT_DEVICE="1"
unset  OMP_DEFAULT_DEVICE    # does the obvious
```

# License

[GNU GENERAL PUBLIC LICENSE // Version 2, June 1991](../GPLv2)

# Author

The OMPi Team, [Parallel Processing Group](http://paragroup.cse.uoi.gr/), University of Ioannina

