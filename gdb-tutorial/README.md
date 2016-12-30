# e-server

Epiphany GDB multicore debugging tutorial.
This tutorial assumes basic knowledge of GDB.

# Start e-server

Start e-server in one terminal.

```
$ e-server --multiprocess
Using the HDF file: /opt/adapteva/esdk/bsps/current/parallella_E16G3_1GB.xml
Listening for RSP on port 51000
```

# Start a program

In a second terminal start a host program:  
Let's use eprime from parallella-examples for this tutorial.  
  
Build eprime:

```
$ cd ~/parallella-examples/apps/eprime
$ git pull
$ ./build.sh
```

Start the program. `EHAL_GDBSERVER` will make `e-hal` start any epiphany
program in a halted debug mode. This is useful if you want to be able to debug
a program from the beginning.

```
$ EHAL_GDBSERVER=yes ./run.sh
```

You will notice that eprime reports 0 primes factored / s. This is because the
epiphany cores are not running yet, because of `EHAL_GDBSERVER`. The next step
is to attach with the e-gdb client and start debugging.

# gdb

In a third terminal, start `e-gdb`. You can either do this on your parallella
or on your local computer if you have esdk-2016.11.x86_64 installed.  

```
$ cd ~/parallella-examples/apps/eprime
$ epiphany-elf-gdb e_prime.elf
Reading symbols from e_prime.elf...done.
```

Enable
[non-stop](https://sourceware.org/gdb/onlinedocs/gdb/Non_002dStop-Mode.html)
mode. This must to be done before connecting to e-server. We also need to
disable pagination as it breaks non-stop.

```
(gdb) set pagination off
(gdb) set non-stop on
```

Connect to the e-server. You'll need to adjust `localhost` to
`parallella.local.` if you use e-gdb from your local computer.

```
(gdb) target extended-remote localhost:51000
Remote debugging using localhost:51000
```

List processes:

```
(gdb) info os processes
pid        user       command    cores
1          root                  0000,0001,0002,0003,0100,0101,0102,0103,0200,0201,0202,0203,0300,0301,0302,0303
```

The default process contains all
cores that have not yet been manually assigned to a workgroup. To create a new
workgroup, use the `monitor workgroup` command. The syntax is `monitor
workgroup [ROW0] [COL0] [ROWS] [COLS]`.

Attach to the default process (workgroup).
```
(gdb) attach 1
[New Thread 1.101]
...
[New Thread 1.404]
0x00000000 in _start ()
...
Thread 16 stopped.
0x00000000 in _start ()
```

Show status for all threads:

```
(gdb) info threads
  Id   Target Id         Frame
* 1    Thread 1.101 (Core: 0000: halted, interruptible) 0x00000000 in _start ()
  2    Thread 1.102 (Core: 0001: halted, interruptible) 0x00000000 in _start ()
...
  16   Thread 1.404 (Core: 0303: halted, interruptible) 0x00000000 in _start ()
```

The `*` in front of thread id 1 indicates the current thread.  
  
Ah, all theeads are stopped. This is because we started the host program with
`EHAL_GDBSERVER=yes`.  That's why eprime reports zero primes/s. You'll notice
that all threads are stopped in `_start()`. This is the low level program entry
point, which is called even before `main()`. So it's possible to set a
breakpoint on any early function call in the epiphany program, even `main()`.
  
  
Let's continue the *current thread* and see what happens in the eprime
terminal.

```
(gdb) continue
Continuing.
```

Now we can see some primes being generated in the eprime terminal.
```
Core (00,00) Tests: 818032 Primes: 102391 Current: 26177027 SQ: 5116
...
Total tests: 1298458 Found primes: 157629
Iterations/sec: 12840.000000
```

Go back to the gdb terminal and stop the thread by pressing Ctrl-C.

```
^C
Thread 1 stopped.
0x00002210 in __umodsi3 ()
```

It's also possible to continue a thread in the background. Append `&` to
continue a thread asynchronously.

```
(gdb) continue &
Continuing.
(gdb)
```

Now it's possible to issue commands to gdb while the thread is running in the
background. Let's verify that the thread is really running.

```
(gdb) info threads
* 1    Thread 1.101 (Core: 0000: running, interruptible) (running)
  2    Thread 1.102 (Core: 0001: halted, interruptible) 0x00000000 in _start ()
...
  16   Thread 1.404 (Core: 0303: halted, interruptible) 0x00000000 in _start ()
```

Use the `interrupt` command to stop a thread that was started asynchronously:

```
(gdb) interrupt
Thread 1 stopped.
0x0000221c in __umodsi3 ()
```

Verify that the thread is stopped:

```
(gdb) info thread 1
  Id   Target Id         Frame
* 1    Thread 1.101 (Core: 0000: halted, interruptible) 0x0000221c in __umodsi3 ()
```

The `-a` flag is a shortcut to continue all threads:

```
(gdb) continue -a
Continuing.
```
In the eprime terminal you will now see that all cores are generating primes.  
  
Press Ctrl-C to get back to the gdb prompt.  
  
Similarly, appending an `&` continues the threads in the background.

```
(gdb) continue -a &
Continuing.
(gdb)
```

Use `info threads` to verify that the threads are running.
```
(gdb) info threads
  Id   Target Id         Frame 
* 1    Thread 1.101 (Core: 0000: running, interruptible) (running)
  2    Thread 1.102 (Core: 0001: running, interruptible) (running)
...
```

To stop all threads, use `interrupt -a`:

```
(gdb) interrupt -a
Thread 1 stopped.
28                      if(number % i == 0)
Thread 2 stopped.
...
```

Set a breakpoint (will be applied to *all* threads):

```
(gdb) break is_prime
Breakpoint 1 at 0x2048: file src/isprime.c, line 23.
(gdb)
```

Continue all threads asynchronously:

```
(gdb) continue -a &
Continuing.
(gdb)
```

All threads are running in the background. When a breakpoint is hit, GDB will
report it:
```
Thread 2 hit Breakpoint 1, is_prime (number=608719203) at src/isprime.c:23
23      {
...
```
  
Finally when done debugging, detach from the process. A detach will resume
all threads:
```
(gdb) detach
Detaching from program: e_prime.elf, process 1
```
