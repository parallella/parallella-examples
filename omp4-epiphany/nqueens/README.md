# NQueens

This program is a modified version of the N queens program found in the Barcelona OpenMP Tasks Suite.

# Building

You need to have [OMPi v2.0.0](http://paragroup.cse.uoi.gr/wpsite/software/ompi) or later installed.
In order to build this application, simply execute:

```Shell
ompicc nqueens.c
```

# Usage

On `esdk.2015.1`, run the application executing the following command:

```Shell
./a.out  [num-of-queens]
```

For older e-SDK versions:

```Shell
./run.sh
```

Please note that the number of queens should be at most 14.

# License

[GNU GENERAL PUBLIC LICENSE // Version 2, June 1991](../GPLv2)

# Author

The OMPi Team, [Parallel Processing Group](http://paragroup.cse.uoi.gr/), University of Ioannina

