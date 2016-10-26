# Game of Life

This application is a fast implementation of Conway's Game of Life.
Every core calculates a fixed number of rows and uses remote writes to
neighbouring cores (with buffers) in order to speed up the calculations.

# Building

You need to have [OMPi v2.0.0](http://paragroup.cse.uoi.gr/wpsite/software/ompi) or later installed.
In order to build this application, simply execute:

```Shell
ompicc gol_fast.c
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

# License

[GNU GENERAL PUBLIC LICENSE // Version 2, June 1991](../GPLv2)

# Author

The OMPi Team, [Parallel Processing Group](http://paragroup.cse.uoi.gr/), University of Ioannina

