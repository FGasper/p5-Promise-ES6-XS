#ifndef PXS_RESULT_H
#define PXS_RESULT_H

#define PERL_NO_GET_CONTEXT

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

typedef struct xspr_result_s xspr_result_t;

typedef enum {
    XSPR_RESULT_NONE,
    XSPR_RESULT_RESOLVED,
    XSPR_RESULT_REJECTED,
    XSPR_RESULT_BOTH
} xspr_result_state_t;

struct xspr_result_s {
    xspr_result_state_t state;
    bool rejection_should_warn;
    SV* result;
    int refs;
};

xspr_result_t* xspr_result_new(pTHX_ xspr_result_state_t state);
xspr_result_t* xspr_result_from_error(pTHX_ const char *error);
void xspr_result_incref(pTHX_ xspr_result_t* result);
void xspr_result_decref(pTHX_ xspr_result_t* result);

#endif
