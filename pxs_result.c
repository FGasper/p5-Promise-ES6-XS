#include "pxs_result.h"

/* Create a new pxs_result_t object with the given number of item slots */
pxs_result_t* pxs_result_new(pTHX_ pxs_result_state_t state, SV* value)
{
    pxs_result_t* result;
    Newxz(result, 1, pxs_result_t);
    result->rejection_should_warn = true;
    result->value = value;
    result->state = state;
    result->refs = 1;
    return result;
}

pxs_result_t* pxs_result_from_error(pTHX_ const char *error)
{
    return pxs_result_new(aTHX_ PXS_RESULT_REJECTED, newSVpv(error, 0));
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

/* Increments the ref count for pxs_result_t */
void pxs_result_incref(pTHX_ pxs_result_t* result)
{
    result->refs++;
}

/* Decrements the ref count for the pxs_result_t, freeing the structure if needed */
void pxs_result_decref(pTHX_ pxs_result_t* result)
{
    //fprintf(stderr, "decref result %p (-> %d)\n", result, result->refs - 1);
    if (--(result->refs) == 0) {
        if (result->state == PXS_RESULT_REJECTED && result->rejection_should_warn) {
            _warn_unhandled_rejection_sv(aTHX_ PXS_RESULT_VALUE(result));
        }

        SvREFCNT_dec( PXS_RESULT_VALUE(result) );
        Safefree(result);
    }
}
