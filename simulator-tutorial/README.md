# Epiphany multicore simulator tutorial

This tutorial gives a brief introduction on how to use the Epiphany multicore
simulator. The simulator is included in Parabuntu 2016.11 and can be used to
run basic programs on a Parallella board.

For performance reasons we recommend to run the simulator on a x86_64 machine.
https://github.com/adapteva/epiphany-sdk/releases/tag/esdk-2016.11

## Installing ESDK 2016.11 for testing the simulator

Follow the instructions here:
https://github.com/adapteva/epiphany-sdk/releases/tag/esdk-2016.11
Download the "-nocross" version

## Hello world

Build:  
```
$ cd helloworld
$ CROSS_COMPILE= ./build.sh
```

Run against simulator:
```
$ e-sim --preset parallella16 --host ./run.sh
  0: Message from eCore 0x8ca ( 3, 2): "Hello World from core 0x8ca!"
  1: Message from eCore 0x84b ( 1, 3): "Hello World from core 0x84b!"
  2: Message from eCore 0x84b ( 1, 3): "Hello World from core 0x84b!"
```

## Domino

Example for Epiphany-V. 1024 cores. Requires 5GB RAM.

```
$ cd domino
$ CROSS_COMPILE= ./build.sh
```

Run against simulator:

```
$ e-sim --preset parallella1k --host ./run.sh
Got 1024 messages
Message path:
○——————————————————————————————▼
⚫▼—————————————————————————————◀
|▶—————————————————————————————▼
[...]
|▶—————————————————————————————▼
|▼—————————————————————————————◀
|▶—————————————————————————————▼
▲——————————————————————————————◀
```

## Stand alone domino

Example for Epiphany-V. 1024 cores. Epiphany only no host. Requires 5GB RAM.
The simulator supports system calls (traps), so thinks like `printf()` work.

```
$ cd domino
$ CROSS_COMPILE= ./build.sh
```

Run against simulator:

```
$ e-sim --preset parallella1k --external-fetch ./domino
Got 1024 messages
Message path:
○——————————————————————————————▼
⚫▼—————————————————————————————◀
|▶—————————————————————————————▼
[...]
|▶—————————————————————————————▼
|▼—————————————————————————————◀
|▶—————————————————————————————▼
▲——————————————————————————————◀
```

## Epiphany examples

You can run most of
(epiphany-examples)[https://github.com/parallella/epiphany-examples] against
`e-sim` in host mode. Examples that use slave DMA will not work (not
implemented in simulator), and a few examples that rely on implicit timing
might fail.

## Redirecting to a directory

The `--redirect-dir DIR` flag redirects simulator stdin/stdout/stdout to DIR.

## Verbose output

`--verbose` enables verbose output. It also makes the individual core
simulators print instruction + memory stats on program exit.

## Tracing execution

`--trace` enables instruction execution tracing. This will slow the simulation
and can easily consume several GBs of disk space.

## e-sim
`e-sim` (symlink to `epiphany-elf-sim`)

Basic usage:  
```
e-sim --preset parallella16 --host HOSTPROGRAM
```

`--preset parallella16` instructs e-sim to use a Parallella-16 configuration.  
Other presets: parallella16, parallella64, and parallella1k.  

The `--host` flag instructs e-sim to. Use `--host` to run e-hal or PAL programs.


```sh
$ cd ~/epiphany-examples/apps/hello-world
$ CROSS_COMPILE= ./build.sh
$ e-sim -p parallella16 --host ./run.sh
  0: Message from eCore 0x8ca ( 3, 2): "Hello World from core 0x8ca!"
  1: Message from eCore 0x84b ( 1, 3): "Hello World from core 0x84b!"
  2: Message from eCore 0x84b ( 1, 3): "Hello World from core 0x84b!"
...
```
The empty `CROSS_COMPILE=` argument will instruct the build script to not
cross-compile the host portion of the example.

Sidenote:
You can run all of epiphany-examples against the simulator with
```
RUNTEST="e-sim -p parallella16 --host " CROSS_COMPILE= ./scripts/build_and_test_all.sh
```

