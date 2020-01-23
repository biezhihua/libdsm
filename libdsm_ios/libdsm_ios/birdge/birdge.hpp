#ifndef birdge_hpp
#define birdge_hpp

#include <stdio.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef long long _DsmNative;

typedef void _DsmSelf;

typedef void (*OnEventFromNative)(_DsmSelf *_Nonnull dsmSelf, int what, const char *_Nullable json);

extern void (*_Nonnull DSM_onEventFromNative)(_DsmSelf *_Nonnull dsmSelf, int what, const char *_Nullable json);

void DSM_init(
        _DsmSelf *_Nullable dsmSelf,
        _DsmNative *_Nullable dsmNative
);

void DSM_release(
        _DsmSelf *_Nullable dsmSelf,
        _DsmNative *_Nullable dsmNative
);

void DSM_startDiscovery(
        _DsmSelf *_Nullable dsmSelf,
        _DsmNative *_Nullable dsmNative,
        int timeout
);

void DSM_stopDiscovery(
        _DsmSelf *_Nullable dsmSelf,
        _DsmNative *_Nullable dsmNative
);

const char *_Nullable DSM_resolve(
        _DsmSelf *_Nullable dsmSelf,
        _DsmNative *_Nullable dsmNative,
        const char *_Nullable name
);

const char *_Nullable DSM_inverse(
        _DsmSelf *_Nullable dsmSelf,
        _DsmNative *_Nullable dsmNative,
        const char *_Nullable address
);

int DSM_login(
        _DsmSelf *_Nullable dsmSelf,
        _DsmNative *_Nullable dsmNative,
        const char *_Nullable host,
        const char *_Nullable loginName,
        const char *_Nullable password
);

int DSM_logout(
        _DsmSelf *_Nullable dsmSelf,
        _DsmNative *_Nullable dsmNative
);

const char *_Nullable DSM_shareGetListJson(
        _DsmSelf *_Nullable dsmSelf,
        _DsmNative *_Nullable dsmNative
);


int DSM_treeConnect(
        _DsmSelf *_Nullable dsmSelf,
        _DsmNative *_Nullable dsmNative,
        const char *_Nullable name);

int DSM_treeDisconnect(_DsmSelf *_Nullable dsmSelf,
        _DsmNative *_Nullable dsmNative, int tid);


const char *_Nullable DSM_find(_DsmSelf *_Nullable dsmSelf,
        _DsmNative *_Nullable dsmNative,
        int tid,
        const char *_Nullable pattern);

const char *_Nullable DSM_fileStatus(_DsmSelf *_Nullable dsmSelf,
        _DsmNative *_Nullable dsmNative,
        int tid, const char *_Nullable path);

#ifdef __cplusplus
}
#endif

#endif
