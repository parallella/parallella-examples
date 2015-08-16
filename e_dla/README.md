# e_dla example Parallella

## How to build and run

    $ sudo su

    $ cd src

    $ make

    $ ./run.sh

Arguments to dla (run.sh has example run)

	./dla 3 16 R 2000

3 - Display in center of screen, 1 displays on left side, 2 displays on right side
16 - Number of Epiphany cores to run on
R - DLA has a Red bias (can be R - Red, G - Green, B - Blue)
2000 - Number of particles per core (32,000 if 2000 and 16 cores)


## Author

[Rob Foster](mailto:<rgfoster1@comcast.net>)

## License

GPL v3
