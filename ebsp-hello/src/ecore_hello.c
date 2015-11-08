#include <e_bsp.h>

int main()
{
    bsp_begin();

    int n = bsp_nprocs();
    int p = bsp_pid();

    ebsp_message("Hello world from core %d/%d", p, n);

    bsp_end();

    return 0;
}
