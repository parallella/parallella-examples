default: multi

multi: src/matmul_multi.c src/matmul_assembly.S src/matmul_internal_multi.ldf src/host_multi.c src/defs_multi.h
	./build_multi.sh

single: src/matmul_main.c src/matmul_assembly.S src/matmul_internal.ldf src/defs.h src/e_dev_main.c src/host_main.c
	./build.sh

