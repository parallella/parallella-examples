# John the Ripper with Parallella support

## Epiphany

For Epiphany support:
```bash
$ make linux-parallella
```

To test bcrypt on Epiphany run:
```bash
$ sudo -E LD_LIBRARY_PATH=$LD_LIBRARY_PATH ./john -te -form=bcrypt-parallella
```


## Zynq-7020

Zynq bitstreams do not have Epiphany support. 

For Zynq support:
```bash
$ make linux-arm32le-neon
```

To load bitstream (src/fpga/bcrypt_60instances.bit.bin) on Zynq FPGA execute following commands as root:
```bash
$ mknod /dev/xdevcfg c 259 0 > /dev/null
$ cat bcrypt_60instances.bit.bin > /dev/xdevcfg
```

To test bcrypt on Zynq-7020 run:
```bash
$ sudo ./john -te -form=bcrypt
```

Due to ZedBoard power issues (suspecting voltage drop), designs with multiple bcrypt instances aren't always reliable. 
To test other bitstream (src/fpga/bcrypt_70instances.bit.bin), change the line #define BF_Nmin 60 in BF_std.h into #define BF_Nmin 70 and recompile.

Slower but reliable code (with bitstream) can be found in src/fpga/JohnTheRipper_Zynq_reliable.tar.gz
