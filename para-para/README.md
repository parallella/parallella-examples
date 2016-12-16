# Parallella "Hello World" Examples

This example shows how to run a simple "hello world" application on the
Parallella using three popular frameworks: OpenMP, MPI, OpenCL


## Building


``$ make``

## Usage

``$ ./run.sh``

## Pre-requisites

NOTE: This applies only to Parabuntu releases older than 2015.11.  

System requirements:

* Ubuntu 14.04
* Parallella Gen 1.1 or later
* Epiphany SDK 5 or later installed
* Coprthr 1.6 installed per instructions below
* openMPI installed per instructions below

This example requires that OpenCL and MPI packages are installed. The Parallella Ubuntu image comes with theses packagaes pre-installed. We rhighly recommend using the latest pre-packaged image available at downloads.parallella.org. Alternatively, the packages can also be installed as shown below:

OpenCL:
```
###Libelf prerequisite
wget www.mr511.de/software/libelf-0.8.13.tar.gz
tar -zxvf libelf-0.8.13.tar.gz
cd libelf-0.8.13
./configure
sudo make install
cd ../

###Libevent prerequisite
wget github.com/downloads/libevent/libevent/libevent-2.0.18-stable.tar.gz
tar -zxvf libevent-2.0.18-stable.tar.gz
cd libevent-2.0.18-stable
./configure
sudo make install
cd ../

###Libconfig prerequisite
wget www.hyperrealm.com/libconfig/libconfig-1.4.8.tar.gz
tar -zxvf libconfig-1.4.8.tar.gz
cd libconfig-1.4.8
./configure
sudo make install
cd ../

###Install parallella opencl package
wget http://www.browndeertechnology.com/code/coprthr-1.6.0-parallella.tgz
tar -zxvf coprthr-1.6.0-parallella.tgz
sudo ./browndeer/scripts/install_coprthr_parallella.sh

### Add paths to .bashrc
echo 'export PATH=/usr/local/browndeer/bin:$PATH' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/usr/local/browndeer/lib:/usr/local/lib:$LD_LIBRARY_PATH' >> ~/.bashrc

### Add paths to root .bashrc
sudo su
echo 'export PATH=/usr/local/browndeer/bin:$PATH' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/usr/local/browndeer/lib:/usr/local/lib:$LD_LIBRARY_PATH' >> ~/.bashrc

### Add paths to .cshrc
echo 'setenv PATH /usr/local/bin:$PATH' >> ~/.cshrc
echo 'setenv LD_LIBRARY_PATH /usr/local/browndeer/lib:/usr/local/lib:$LD_LIBRARY_PATH' >> ~/.cshrc
```

MPI:
```
wget http://www.open-mpi.org/software/ompi/v1.8/downloads/openmpi-1.8.1.tar.gz
tar -zxvf openmpi-1.8.1.tar.gz
cd openmpi-1.8.1
./configure --prefix=/usr/local \
            --enable-mpirun-prefix-by-default \
            --enable-static 
make all
sudo make install
```

## License

BSD 3-clause License

## Author

[Andreas Olofsson](https://github.com/aolofsson)
