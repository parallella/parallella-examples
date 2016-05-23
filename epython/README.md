# Running Python code on the Epiphany

This illustrates installing a special version of Python, Epiphany Python, and then running some simple examples written in ePython on the Epiphany cores. ePython is subset of Python and is designed to be a quick and easy way of writing parallel codes for the Epiphany co-processor. It requires no prior knowledge of parallel programming and even those with limited programming experience will be able to quickly develop parallel codes.

## Obtaining ePython

ePython is open source and available on GitHub. There are two ways of obtaining and installing ePython, in this section we will concentrate on the automatic way of installing ePython which should suit most people

### Automatically installing ePython

The install.sh script in this directory will download, make and then install ePython. Just issue:

```
./install.sh
```

from the command line. It should just run, but if there are any permission issues in executing this script then issue chmod +x install.sh 

The install phase will copy ePython to a central location (/usr/bin) and this is done as sudo so you might be prompted for the parallella password. Lastly you will need to start a new bash terminal which has the Python paths correctly set and every time bash starts from now on it will be correctly configured for ePython. Just issue:

```
bash
```

from the command line and congratulations, all done - ePython is installed!

## Running 

We have provided a simple hello world example in this repository and there are plenty of additional examples (and documentation) in epython/docs/examples which has been downloaded as part of the ePython installation above.

Firstly, the hello world example is in hello.py, just issue:

```
epython hello.py
```

This will execute hello.py on each Epiphany core and every core will display its ID along with the total number of cores (16 if you are the common 16 core Epiphany chip):

```
[device 1] Hello world from core 1 out of 16 cores
[device 2] Hello world from core 2 out of 16 cores
[device 3] Hello world from core 3 out of 16 cores
......
```

This illustrates how simple it is to write and run code on the Epiphany chip, more advanced examples which explore parallel capabilities of the chip along with some real world computation examples are in epython/docs/examples

## Manual installation

If you wish to manually install ePython then there are two steps which must be taken (cloning the repository and making ePython) and one optional step (installing ePython). Issue:

```
git clone https://github.com/mesham/epython.git
```

from the command line and then cd into the newly created epython directory and issue:

```
make
```

This will build ePython and you will see a number of executables in the current directory. These can be run directly from that location, but if you want to use ePython from any directory on the machine then it needs to be in a central location, in this case issue:

```
make install
```

which will copy the executables into /usr/bin, copy the ePython modules to a central location and set up the Python paths in your .bashrc file.

### Uninstalling

To uninstall ePython then issue:

```
sudo make uninstall
```

from the epython directory, this will delete all the the installed files.

## Licence

This example and ePython are available under the FreeBSD licence

## Authors

Nick Brown

## Further tutorials and documentation

A number of tutorials are being developed for ePython on the Parallella forum:

- Running your own code on the Epiphany in 60 seconds [click here](http://www.parallella.org/forums/viewtopic.php?f=49&t=3249&sid=9903194a709b6255225689b60a8a4268) where we discuss installing ePython and writing some very simple example codes
- Part two [click here](http://www.parallella.org/forums/viewtopic.php?f=49&t=3707&sid=9903194a709b6255225689b60a8a4268) which focusses on the parallelism of the Epiphany cores and using the same building blocks that HPC programmers use we look at the different ways in which the cores can communicate and a real world example running on these cores.
