# cross compiling on x86_64 host

# -mshort-calls: OK
# -msmall16: still broken
# -m1reg-r63: OK
# -mfp-mode=int: OK

echo Cross compiling on x86_64 host
echo.
echo.
e-gcc -Ofast -mfp-mode=int -mshort-calls -m1reg-r63 -T /opt/adapteva/esdk/bsps/current/internal.ldf src/e_e2g.c -S -le-lib
echo.
