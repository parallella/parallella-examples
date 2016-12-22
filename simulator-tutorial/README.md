# Epiphany multicore simulator tutorial

This tutorial gives a brief introduction on how to use the Epiphany multicore
simulator.  
  
The simulator is included in Parabuntu 2016.11 and can be used to run basic
programs on a Parallella board.
  
For performance reasons we recommend to run the simulator on a x86_64 machine.  
The Epiphany-V (1024 cores) examples require 8GB of free RAM.  

## Downloading ESDK 2016.11

Download page for ESDK 2016.11:  
https://github.com/adapteva/epiphany-sdk/releases/tag/esdk-2016.11  
Select the x86_64 "-nocross" version.  
  
The x86_64 "nocross" build contains native x86_64 Epiphany host libraries
(e-hal, e-loader, and PAL).

## Installing ESDK 2016.11

Follow the instructions here:  
https://github.com/adapteva/epiphany-sdk/releases/tag/esdk-2016.11

## Hello world

Build:  
```
$ cd hello-world
$ CROSS_COMPILE= ./build.sh
```

The empty `CROSS_COMPILE=` argument instructs the build script to not
cross-compile the host portion of the example.  
  
Run against simulator:
```
$ e-sim --preset parallella16 --host ./run.sh
  0: Message from eCore 0x8ca ( 3, 2): "Hello World from core 0x8ca!"
  1: Message from eCore 0x84b ( 1, 3): "Hello World from core 0x84b!"
  2: Message from eCore 0x84b ( 1, 3): "Hello World from core 0x84b!"
```

* `--preset parallella16` makes the simulator use Parallella-16 configuration.
* `--host ./run.sh` instructs the simulator that the program is a host program.
   In this mode the core simulators starts up in idle mode. The host program
   will load and start Epiphany binaries via e-hal / PAL simulator targets.
   Other presets: `parallella16`, `parallella64`, and `parallella1k`.

## Domino

Example for Epiphany-V. 1024 cores. Requires 8GB of free RAM.

```
$ cd domino
$ CROSS_COMPILE= ./build.sh
```

### Simulating a Parallella-1K

Use the parallella1k preset to simulate a Parallella board with a 1024 Epiphany-V chip

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

### Other presets

The domino example is dynamic and will adopt to any size you give it.

Simulating a Parallella-16:  
```
$ e-sim --preset parallella16 --host ./run.sh
Got 16 messages
Message path:
○——▼
⚫▼—◀
|▶—▼
▲——◀
```

Simulating a Parallella-64:  
```
$ e-sim --preset parallella64 --host ./run.sh
Got 64 messages
Message path:
○——————▼
⚫▼—————◀
|▶—————▼
|▼—————◀
|▶—————▼
|▼—————◀
|▶—————▼
▲——————◀
```

## Stand alone domino

Stand alone example for Epiphany-V (1024 cores).
The example is Epiphany only and has no host program. The example requires 8GB
of free RAM. The simulator supports system calls (traps), so things like
`printf()` will work.  
  
Building:  
```
$ cd domino-standalone
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

## Redirecting to a directory

The `--redirect-dir DIR` flag redirects simulator stdin/stdout/stdout to DIR.

## Verbose output

`--verbose` enables verbose output. It also makes the individual core
simulators print instruction + memory stats on program exit.

## Tracing execution

`--trace` enables instruction execution tracing. This will slow the simulation
and can easily consume several GBs of disk space.

## Epiphany examples

You can run most of
[epiphany-examples](https://github.com/parallella/epiphany-examples) against
`e-sim` in host mode. Examples that use slave DMA will not work (not
implemented in simulator), and a few examples that rely on implicit timing
might fail.

```sh
$ cd ~/epiphany-examples/apps/eprime
$ CROSS_COMPILE= ./build.sh
$ e-sim -p parallella16 --host ./run.sh
Core (00,00) Tests: 818032 Primes: 102391 Current: 26177027 SQ: 5116
...
Total tests: 1298458 Found primes: 157629
...
```

You can run all of epiphany-examples against the simulator with:
```
RUNTEST="e-sim -p parallella16 --host " CROSS_COMPILE= ./scripts/build_and_test_all.sh
```

## Gotchas


* When the host (armv7l or x86_64) and device (Epiphany) have different
  architectures you should explicitly define size and layout for data
  structures shared between the host and Epiphany. If you must have pointers in
  a shared data structure, use the union trick below to make sure the struct
  have the same layout on both 64- and 32-bit architectures.

`shared.h`:
```c
#include <stdint.h>
struct msgbox {
    uint32_t flag;
    union {
        uint64_t:64;
        void *ptr;
    } __attribute__((packed));
} __attribute__((packed));
```

* Avoid using implicit synchronization, e.g. calls to `sleep()`. The simulator
  will have much longer execution time compared to real hardware.
  
Avoid this:
```c
    e_load_group("foo.elf", &dev, 0, 0, platform.rows, platform.cols, E_TRUE);
    usleep(1000000); /* Wait for cores to finish */
    do_something_with_result();
```

Instead:

`shared.h`:
```c
#define FLAG_OFFSET 0
#define FLAG_ADDR 0x8e000000
```

`main.c`:
```c
#include "shared.h"
    ...
int main(int argc, char **argv)
{

    const uint32_t zero = 0;
    uint32_t done = 0;

    /* Allocate memory for flag */
    e_alloc(&emem, FLAG_OFFSET, sizeof(flag));

    /* Clear flag */
    e_write(&emem, 0, 0, FLAG_OFFSET, &zero, sizeof(done));
    e_load_group("foo.elf", &dev, 0, 0, platform.rows, platform.cols, E_TRUE);

    while (!done)
        e_read(&emem, 0, 0, FLAG_OFFSET, &done, sizeof(done));

    do_something_with_result();
```

`emain.c`:
```c
#include "shared.h"

int main()
{
    volatile uint32_t *flag = (uint32_t *) FLAG_ADDR;
    compute_something();
    *flag = 1;
}
```
