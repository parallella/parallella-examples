# e-server

(Work in progress)  
Epiphany GDB multicore debugging tutorial.

# Start e-server

Start e-server in one terminal.

```
$ e-server --multiprocess
```

# Start a program

In a second terminal start a host program:  
Let's use e-prime from epiphany-examples for this tutorial.  
  
Build e-prime:

```
$ cd ~/epiphany-examples/apps/e-prime
$ git pull
$ ./build.sh
```

Start the program. `EHAL_GDBSERVER` will make `e-hal` start any epiphany
program in a halted debug mode. This is useful if you want to be able to debug
a program from the beginning.

```
$ EHAL_GDBSERVER=yes ./run.sh
```

You will notice that e-prime reports 0 primes factored / s. This is because the
epiphany cores are not running yet, because of `EHAL_GDBSERVER`. The next step
is to attach with the e-gdb client and start debugging.

# gdb

In a third terminal, start `e-gdb`. You can either do this on your parallella
or on your local computer if you have esdk-2016.11.x86_64 installed.  

```
$ cd ~/epiphany-examples/apps/e-prime
$ epiphany-elf-gdb e_prime.elf
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
```

List processes:

```
(gdb) info os processes
```

Attach to the default process (workgroup). The default process contains all
cores that have not yet been manually assigned to a workgroup. To create a new
workgroup, use the `monitor workgroup` command. The syntax is `monitor
workgroup [ROW0] [COL0] [ROWS] [COLS]`.

```
(gdb) attach 1
```

Show status for all threads:

```
(gdb) info threads
```

Ah, all threads are stopped. This is because we started the host program with
`EHAL_GDBSERVER=yes`.  That's why e-prime reports zero primes/s. You'll notice
that all threads are stopped in `_start()`. This is the low level program entry
point, which is called even before `main()`. So it's possible to set a
breakpoint on any early function call in the epiphany program, even `main()`.


Now, let's continue the *current thread* and see what happens in the e-prime
terminal.

```
(gdb) continue
```

Finally we can see some primes being generated in the e-prime terminal.

```
Press Ctrl-C to stop the thread
```

It's also possible to continue a thread in the background. Append `&` to
continue a thread asynchronously.

```
(gdb) continue &
```

Now it's possible to issue commands to gdb while the thread is running in the
background.  Let's verify that the thread is really running.

```
(gdb) info threads
```

Use the `interrupt` command to stop a thread that was started asynchronously:

```
(gdb) interrupt
```

Verify that the thread is stopped:

```
(gdb) info threads
```

The `-a` flag is a shortcut to continue all threads:

```
(gdb) continue -a &
```

Similarly `-a` can also be used to interrupt all threads:

```
(gdb) interrupt -a
```

Set a breakpoint (will be applied to *all* threads):

```
(gdb) break is_prime
```

Continue all threads asynchronously:

```
(gdb) continue -a &
```

Finally when you're done debugging, detach from process:

```
(gdb) detach
```
