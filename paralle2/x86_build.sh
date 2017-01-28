# cross compiling on x86_64 host, assuming /opt/adapteva as default path

e-gcc -Ofast -mfp-mode=int -mshort-calls -m1reg-r63 -T /opt/adapteva/esdk/bsps/current/internal.ldf src/e_e2g.c -o bin/e_e2g.elf -le-lib
