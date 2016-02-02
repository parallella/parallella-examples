Each core acts as an autonomous cell in Conway's game of life. The program doesn't
show every changes since each core are autonomous. It simply repeatedly prints
the state of each cells a fixed number of times.  
Borders are considered as permanently living cells.

to build and run :
```
./build.sh && ./main.elf [number of iterations]
```

The number of iterations is an optional parameter.

The expected outcome may differ every time! Here is an example :

```
X	X	X	X	X	X
X	O	X	X	O	X
X	O	O	O	O	X
X	O	O	O	X	X
X	O	X	O	O	X
X	X	X	X	X	X

X	X	X	X	X	X
X	O	X	X	O	X
X	X	O	O	O	X
X	O	O	O	X	X
X	O	X	O	O	X
X	X	X	X	X	X

X	X	X	X	X	X
X	O	O	O	O	X
X	O	O	X	O	X
X	X	O	X	O	X
X	O	O	O	O	X
X	X	X	X	X	X
```

At the end, prints for each cells the number of iterations and the status of the
sticky overflow flag.

#### License

MIT
