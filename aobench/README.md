# aobench

[aobench](http://code.google.com/p/aobench/) on Parallella.

![aobench](/aobench/img/aobench_parallella.png)

Youtube

http://www.youtube.com/watch?v=_t4p4Is0Z3E

Based on Shodruky's mandelbrot example

https://github.com/parallella/parallella-examples/tree/master/mandelbrot

## How to build and run

    $ make

Go to framebuffer mode(CTRL + ALT + F2)

    $ ./run.sh

Will render animation of aobench. 
After execution, you can go back to GUI by CTRL + ALT + F7

## Note

-O3 option doesn't work(seems causing stack overrun at runtime).

epiphany core doesn't have division, sqrt, etc in HW, thus we have to provide (approximate) functions of these for better performance.

## Author

[Syoyo Fujita](mailto:syoyo@lighttransport.com)

## License

3-clause BSD license
