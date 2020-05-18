#include "birdge.hpp"
#include "Dsm.h"
#include "Log.h"
#include "json.h"

using json = nlohmann::json;

static int EVENT_TYPE_ON_DISCOVERY_ADD = 0;
static int EVENT_TYPE_ON_DISCOVERY_REMOVE = 1;

void (*_Nonnull DSM_onEventFromNative)(_DsmHolder *_Nonnull dsmSelf, int what, const char *_Nullable json) = nullptr;

class BirdgeDsm : public Dsm {

public:
    _DsmHolder *_dsmSelf = nullptr;
    OnEventFromNative onEvent = nullptr;

private:
    void onDiscoveryEntryAdded(const char *json) override {
        LOGD("[%s] json=%s", __func__, json);
        if (onEvent != nullptr) {
            (onEvent)(_dsmSelf, EVENT_TYPE_ON_DISCOVERY_ADD, json);
        }
    }

    void onDiscoveryEntryRemoved(const char *json) override {
        LOGD("[%s] json=%s", __func__, json);
        if (onEvent != nullptr) {
            (onEvent)(_dsmSelf, EVENT_TYPE_ON_DISCOVERY_REMOVE, json);
        }
    }

};

static BirdgeDsm *getBirdgeDsm(_DsmHolder *_Nullable dsmSelf, _DsmNative *_Nullable dsmNative) {
    if (dsmSelf != nullptr && dsmNative != nullptr && *dsmNative != 0) {
        return (BirdgeDsm *) *dsmNative;
    }
    LOGE("[%s] Params is illegal", __func__);
    return nullptr;
}


static BirdgeDsm *setBirdgeDsm(_DsmHolder *_Nullable dsmSelf, _DsmNative *_Nullable dsmNative, long dsm) {
    BirdgeDsm *old = getBirdgeDsm(dsmSelf, dsmNative);
    if (dsmSelf != nullptr && dsmNative != nullptr) {
        *dsmNative = dsm;
    }
    return old;
}

void DSM_init(
        _DsmHolder *_Nullable dsmSelf,
        _DsmNative *_Nullable dsmNative
) {
    BirdgeDsm *dsm = getBirdgeDsm(dsmSelf, dsmNative);
    if (dsm == nullptr) {
        dsm = new BirdgeDsm();
        dsm->onEvent = DSM_onEventFromNative;
        dsm->_dsmSelf = dsmSelf;
        if (dsm->onEvent == nullptr) {
            LOGE("[%s] Event is null", __func__);
        }
        DSM_onEventFromNative = nullptr;
        setBirdgeDsm(dsmSelf, dsmNative, (long) dsm);
        LOGD("[%s] Initialized dsm=%ld", __func__, (long) dsm);
    } else {
        LOGD("[%s] No need to repeat initialization", __func__);
    }
}


void DSM_release(
        _DsmHolder *_Nullable dsmHolder,
        _DsmNative *_Nullable dsmNative
) {
    BirdgeDsm *dsm = getBirdgeDsm(dsmHolder, dsmNative);
    if (dsm != nullptr) {
        dsm->_dsmSelf = nullptr;
        dsm->onEvent = nullptr;
        setBirdgeDsm(dsmHolder, dsmNative, 0);
        dsm = nullptr;
        dsmHolder = nullptr;
        dsmNative = nullptr;
        delete dsm;
        LOGD("[%s] Destroyed", __func__);
    } else {
        LOGD("[%s] No need to repeat destroy", __func__);
    }
}

void DSM_startDiscovery(
        _DsmHolder *_Nullable dsmHolder,
        _DsmNative *_Nullable dsmNative,
        int timeout
) {
    BirdgeDsm *dsm = getBirdgeDsm(dsmHolder, dsmNative);
    if (dsm != nullptr) {
        if (timeout >= 0) {
            int result = dsm->startDiscovery((unsigned int) (timeout));
            if (result == 0) {
                LOGD("[%s] Start discovering ...", __func__);
            } else {
                LOGE("[%s] Start discovery failure", __func__);
            }
        } else {
            LOGE("[%s] Timeout must be >= 0", __func__);
        }
    } else {
        LOGE("[%s] Dsm is null, please initialize", __func__);
    }
}

void DSM_stopDiscovery(
        _DsmHolder *_Nullable dsmHolder,
        _DsmNative *_Nullable dsmNative
) {
    BirdgeDsm *dsm = getBirdgeDsm(dsmHolder, dsmNative);
    if (dsm != nullptr) {
        int result = dsm->stopDiscovery();
        if (result == 0) {
            LOGD("[%s] Stop Discovery", __func__);
        } else {
            LOGE("[%s] Stop Discovery failure", __func__);
        }
    } else {
        LOGE("[%s] Dsm is null, please initialize", __func__);
    }
}

const char *_Nullable DSM_resolve(
        _DsmHolder *_Nullable dsmHolder,
        _DsmNative *_Nullable dsmNative,
        const char *_Nullable name
) {
    BirdgeDsm *dsm = getBirdgeDsm(dsmHolder, dsmNative);
    if (dsm != nullptr) {
        const char *result = dsm->resolve(name);
        if (result == nullptr) {
            LOGE("[%s] resolve failed name=%s result=%s", __func__, name, result);
            return "";
        } else {
            return result;
        }
    }
    LOGE("[%s] Dsm is null, please initialize", __func__);
    return "";
}

const char *_Nullable DSM_inverse(
        _DsmHolder *_Nullable dsmHolder,
        _DsmNative *_Nullable dsmNative,
        const char *_Nullable address
) {
    BirdgeDsm *dsm = getBirdgeDsm(dsmHolder, dsmNative);
    if (dsm != nullptr) {
        const char *result = dsm->inverse(address);
        if (result == nullptr) {
            LOGE("[%s] Inverse failed address=%s result=%s", __func__, address, result);
            return "";
        } else {
            return result;
        }
    }
    LOGE("[%s] Dsm is null, please initialize", __func__);
    return "";
}

int DSM_login(
        _DsmHolder *_Nullable dsmHolder,
        _DsmNative *_Nullable dsmNative,
        const char *_Nullable host,
        const char *_Nullable loginName,
        const char *_Nullable password
) {
    BirdgeDsm *dsm = getBirdgeDsm(dsmHolder, dsmNative);
    if (dsm != nullptr) {
        return dsm->login(host, loginName, password);
    }
    LOGE("[%s] Dsm is null", __func__);
    return DSM_ERROR;
}

int DSM_logout(
        _DsmHolder *_Nullable dsmHolder,
        _DsmNative *_Nullable dsmNative
) {
    BirdgeDsm *dsm = getBirdgeDsm(dsmHolder, dsmNative);
    if (dsm != nullptr) {
        int result = dsm->logout();
        return result;
    }
    LOGE("[%s] Dsm is null, please initialize", __func__);
    return DSM_ERROR;
}

const char *_Nullable DSM_shareGetListJson(
        _DsmHolder *_Nullable dsmHolder,
        _DsmNative *_Nullable dsmNative
) {

    BirdgeDsm *dsm = getBirdgeDsm(dsmHolder, dsmNative);
    if (dsm != nullptr) {
        string *json = dsm->shareGetList();
        if (json == nullptr) {
            LOGE("[%s] Share get list failed", __func__);
            return "";
        } else {
            const char *result = json->c_str();
            delete json;
            return result;
        }
    }
    LOGE("[%s] Dsm is null, please initialize", __func__);
    return "";
}

int DSM_treeConnect(
        _DsmHolder *_Nullable dsmHolder,
        _DsmNative *_Nullable dsmNative,
        const char *_Nullable name
) {
    BirdgeDsm *dsm = getBirdgeDsm(dsmHolder, dsmNative);
    if (dsm != nullptr) {
        int tid = dsm->treeConnect(name);
        return tid;
    }
    LOGE("[%s] Dsm is null, please initialize", __func__);
    return DSM_ERROR;
}

int DSM_treeDisconnect(
        _DsmHolder *_Nullable dsmHolder,
        _DsmNative *_Nullable dsmNative, int tid
) {
    BirdgeDsm *dsm = getBirdgeDsm(dsmHolder, dsmNative);
    if (dsm != nullptr) {
        return dsm->treeDisconnect(tid);
    }
    LOGE("[%s] Dsm is null, please initialize", __func__);
    return DSM_ERROR;
}

const char *_Nullable DSM_find(
        _DsmHolder *_Nullable dsmHolder,
        _DsmNative *_Nullable dsmNative,
        int tid,
        const char *_Nullable pattern
) {
    BirdgeDsm *dsm = getBirdgeDsm(dsmHolder, dsmNative);
    if (dsm != nullptr) {
        string *json = dsm->find(tid, pattern);
        if (json == nullptr) {
            LOGE("[%s] Find file list failed, pattern=%s", __func__, pattern);
            return "";
        } else {
            const char *result = json->c_str();
            delete json;
            return result;
        }
    }
    LOGE("[%s] Dsm is null, please initialize", __func__);
    return "";
}

const char *_Nullable DSM_fileStatus(
        _DsmHolder *_Nullable dsmHolder,
        _DsmNative *_Nullable dsmNative,
        int tid,
        const char *_Nullable path
) {

    BirdgeDsm *dsm = getBirdgeDsm(dsmHolder, dsmNative);
    if (dsm != nullptr) {
        string *json = dsm->fileStatus(tid, path);
        if (json == nullptr) {
            LOGE("[%s] Query file status failed, path=%s", __func__, path);
            return "";
        } else {
            const char *result = json->c_str();
            delete json;
            return result;
        }
    }
    LOGE("[%s] Dsm is null, please initialize", __func__);
    return "";
}
