#ifndef PXS_RESULT_H
#define PXS_RESULT_H

#define PERL_NO_GET_CONTEXT

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

typedef struct pxs_result_s pxs_result_t;

typedef enum {
    PXS_RESULT_NONE,
    PXS_RESULT_RESOLVED,
    PXS_RESULT_REJECTED,
    PXS_RESULT_BOTH
} pxs_result_state_t;

struct pxs_result_s {
    pxs_result_state_t state;
    bool rejection_should_warn;
    SV* result;
    int refs;
};

pxs_result_t* pxs_result_new(pTHX_ pxs_result_state_t state);
pxs_result_t* pxs_result_from_error(pTHX_ const char *error);
void pxs_result_incref(pTHX_ pxs_result_t* result);
void pxs_result_decref(pTHX_ pxs_result_t* result);

#endif
