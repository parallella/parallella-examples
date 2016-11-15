# John the Ripper with Parallella support

[John the Ripper](http://www.openwall.com/john/) is a fast password cracker, currently available for many flavors of Unix, Windows, DOS, BeOS, and OpenVMS. Its primary purpose is to detect weak Unix passwords. Besides several crypt(3) password hash types most commonly found on various Unix systems, supported out of the box are Windows LM hashes, plus lots of other hashes and ciphers in the community-enhanced version.

## Implementation

This release has supported added for the Parallella board, with implementation of bcrypt on the Epiphany accelerator and in the Zynq programmable logic.

## Building and usage

### Epiphany

For Epiphany support:
```bash
$ cd src
$ make linux-parallella
```

To test bcrypt on Epiphany run:
```bash
$ cd run
$ ./john -te -form=bcrypt-parallella
```

### Zynq-7020

Note that the Zynq PL bitstreams do not have Epiphany support!

For Zynq support:
```bash
$ make linux-arm32le-neon
```

To load bitstream (src/fpga/bcrypt_60instances.bit.bin) on Zynq FPGA execute following commands as root:
```bash
$ mknod /dev/xdevcfg c 250 0 > /dev/null
$ cat bcrypt_60instances.bit.bin > /dev/xdevcfg
```

To test bcrypt on Zynq-7020 run:
```bash
$ sudo ./john -te -form=bcrypt
```

Due to ZedBoard power issues (suspecting voltage drop), designs with multiple bcrypt instances aren't always reliable. 
To test other bitstream (src/fpga/bcrypt_70instances.bit.bin), change the line #define BF_Nmin 60 in BF_std.h into #define BF_Nmin 70 and recompile.

Slower but reliable code (with bitstream) can be found in src/fpga/JohnTheRipper_Zynq_reliable.tar.gz

## License

GPL v2

## Authors

Parallella support contributed by Katja Malvoni.

John the Ripper copyright Solar Designer et al. For details see the file doc/CREDITS.
