#include <host_bsp.h>
#include <stdio.h>

int main(int argc, char **argv)
{
    // Initialize the BSP system
    bsp_init("ecore_hello.elf", argc, argv);

    // Initialize the Epiphany system and load the binary
    bsp_begin(bsp_nprocs());

    // Run the program on the Epiphany cores
    ebsp_spmd();

    // Finalize
    bsp_end();

    return 0;
}
