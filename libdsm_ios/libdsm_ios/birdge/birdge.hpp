#ifndef birdge_hpp
#define birdge_hpp

#include <stdio.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef long long _DsmNative;

typedef void _DsmHolder;

typedef void (*OnEventFromNative)(_DsmHolder *_Nonnull dsmHolder, int what, const char *_Nullable json);

extern void (*_Nonnull DSM_onEventFromNative)(_DsmHolder *_Nonnull dsmHolder, int what, const char *_Nullable json);

void DSM_init(
        _DsmHolder *_Nullable dsmSelf,
        _DsmNative *_Nullable dsmNative
);

void DSM_release(
        _DsmHolder *_Nullable dsmSelf,
        _DsmNative *_Nullable dsmNative
);

void DSM_startDiscovery(
        _DsmHolder *_Nullable dsmSelf,
        _DsmNative *_Nullable dsmNative,
        int timeout
);

void DSM_stopDiscovery(
        _DsmHolder *_Nullable dsmSelf,
        _DsmNative *_Nullable dsmNative
);

const char *_Nullable DSM_resolve(
        _DsmHolder *_Nullable dsmSelf,
        _DsmNative *_Nullable dsmNative,
        const char *_Nullable name
);

const char *_Nullable DSM_inverse(
        _DsmHolder *_Nullable dsmSelf,
        _DsmNative *_Nullable dsmNative,
        const char *_Nullable address
);

int DSM_login(
        _DsmHolder *_Nullable dsmSelf,
        _DsmNative *_Nullable dsmNative,
        const char *_Nullable host,
        const char *_Nullable loginName,
        const char *_Nullable password
);

int DSM_logout(
        _DsmHolder *_Nullable dsmSelf,
        _DsmNative *_Nullable dsmNative
);

const char *_Nullable DSM_shareGetListJson(
        _DsmHolder *_Nullable dsmSelf,
        _DsmNative *_Nullable dsmNative
);


int DSM_treeConnect(
        _DsmHolder *_Nullable dsmSelf,
        _DsmNative *_Nullable dsmNative,
        const char *_Nullable name);

int DSM_treeDisconnect(_DsmHolder *_Nullable dsmSelf,
        _DsmNative *_Nullable dsmNative, int tid);


const char *_Nullable DSM_find(_DsmHolder *_Nullable dsmSelf,
        _DsmNative *_Nullable dsmNative,
        int tid,
        const char *_Nullable pattern);

const char *_Nullable DSM_fileStatus(_DsmHolder *_Nullable dsmSelf,
        _DsmNative *_Nullable dsmNative,
        int tid, const char *_Nullable path);

#ifdef __cplusplus
}
#endif

#endif
