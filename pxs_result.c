#include "pxs_result.h"

/* Create a new xspr_result_t object with the given number of item slots */
xspr_result_t* xspr_result_new(pTHX_ xspr_result_state_t state)
{
    xspr_result_t* result;
    Newxz(result, 1, xspr_result_t);
    //fprintf(stderr, "NEW RESULT %p\n", result);
    result->rejection_should_warn = true;
    result->state = state;
    result->refs = 1;
    return result;
}

xspr_result_t* xspr_result_from_error(pTHX_ const char *error)
{
    xspr_result_t* result = xspr_result_new(aTHX_ XSPR_RESULT_REJECTED);
    result->result = newSVpv(error, 0);
    return result;
}

void _call_pv_with_args( pTHX_ const char* subname, SV** args, unsigned argscount )
{
    // --- Almost all copy-paste from “perlcall” … blegh!
    dSP;

    ENTER;
    SAVETMPS;

    PUSHMARK(SP);
    EXTEND(SP, argscount);

    unsigned i;
    for (i=0; i<argscount; i++) {
        PUSHs(args[i]);
    }

    PUTBACK;

    call_pv(subname, G_VOID);

    FREETMPS;
    LEAVE;

    return;
}

static inline void _warn_unhandled_rejection_sv(pTHX_ SV* reason) {
    SV* warn_args[] = { reason };

    _call_pv_with_args(aTHX_ "Promise::XS::Promise::_warn_unhandled", warn_args, 1);
}

/* Increments the ref count for xspr_result_t */
void xspr_result_incref(pTHX_ xspr_result_t* result)
{
    //fprintf(stderr, "incref result %p (-> %d)\n", result, result->refs + 1);
    result->refs++;
}

/* Decrements the ref count for the xspr_result_t, freeing the structure if needed */
void xspr_result_decref(pTHX_ xspr_result_t* result)
{
    //fprintf(stderr, "decref result %p (-> %d)\n", result, result->refs - 1);
    if (--(result->refs) == 0) {
//fprintf(stderr, "start reap result %p (state: %d), should warn? %d\n", result, result->state, result->rejection_should_warn);
//sv_dump(result->result);
        if (result->state == XSPR_RESULT_REJECTED && result->rejection_should_warn) {
//fprintf(stderr, "warn from decref %p\n", result);
            _warn_unhandled_rejection_sv(aTHX_ result->result);
        }

//fprintf(stderr, "reap result %p\n", result);
        SvREFCNT_dec(result->result);
        Safefree(result);
    }
}
