#pragma once

#ifdef __cplusplus
extern "C" {
#endif

typedef unsigned (*checkRestart_t)();
typedef void (*reportSuccess_t)(mpz_t, unsigned);

void rh_oneTimeInit(reportSuccess_t, checkRestart_t);
void rh_search(mpz_t);

#ifdef __cplusplus
}
#endif
