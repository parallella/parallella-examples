Pseudo Eternity II solver under Parallella !

Demo with a 10x10 subproblem with 16 cores running in parallel.

A single eCore reaches 3 Mn/s, that's a tremendous 48 Mn/s for 4.7 W !
My high-end computer reaches 130 Mn/s with a single core and heavy optimizations, but it consumes 72 W.

This is only the beginning with a basic algorithm, I'm confident we can reach 80 Mn/s with a single 16-core Parallella :D
For your information a single ARM core with the same basic algorithm reaches 6 Mn/s.
This kind of problem would be a good candidate to run under the unused parts of the FPGA... that's another story. For experts.

***

How to run the demo under a 16-core Parallella:
./build.sh
time ./run.sh

Please check you use a 16-core Epiphany like mine: E16G301, a Kickstarter model with Zynq 7020 and a 'headless' configuration.
If not the case, you may adapt the sources: src/e2.c and src/e_e2.c
This kind of problem is a perfect candidate for clusters too.
You can easily tweak this code if you have a 64-core Parallella (if you don't know how to code it, just sell it to me lol)

