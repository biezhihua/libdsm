#include <jni.h>
#include <stdio.h>
#include <string>
#include <android/log.h>
#include "Log.h"
#include "Dsm.h"
#include "nlohmann/json.h"
#include "JniHelp.h"

extern "C" {
#include <arpa/inet.h>
#include "bdsm/bdsm.h"
#include "bdsm/netbios_ns.h"
}

using json = nlohmann::json;

static int EVENT_TYPE_ON_DISCOVERY_ADD = 0;
static int EVENT_TYPE_ON_DISCOVERY_REMOVE = 1;

const char *CLASS_NAME = "open/android/lib/dsm/Dsm";

static JavaVM *javaVM = nullptr;

static JNIEnv *getJNIEnv() {
    JNIEnv *env;
    assert(javaVM != nullptr);
    if (javaVM->GetEnv((void **) &env, JNI_VERSION_1_6) != JNI_OK) {
        return nullptr;
    }
    return env;
}

static void onEvent(jobject self, jmethodID method, int what, const char *json) {
    JNIEnv *env = getJNIEnv();
    bool attachFlag = (javaVM->AttachCurrentThread(&env, nullptr) >= 0);
    if (env != nullptr) {

        env->CallVoidMethod(self, method, what, env->NewStringUTF(json));

        if (env->ExceptionCheck()) {
            jthrowable exc = env->ExceptionOccurred();
            jniLogException(env, ANDROID_LOG_ERROR, "[DSM][NATIVE]", exc);
            env->ExceptionClear();
        }

        if (attachFlag) {
            javaVM->DetachCurrentThread();
        }
    }
}

class JniDsm : public Dsm {

public:
    jobject globalSelf = nullptr;
    jfieldID dsmFieldId = nullptr;
    jmethodID eventMethodId = nullptr;

private:
    void onDiscoveryEntryAdded(const char *json) override {
        LOGD("[%s] json=%s", __func__, json);
        onEvent(globalSelf, eventMethodId, EVENT_TYPE_ON_DISCOVERY_ADD, json);
    }

    void onDiscoveryEntryRemoved(const char *json) override {
        LOGD("[%s] json=%s", __func__, json);
        onEvent(globalSelf, eventMethodId, EVENT_TYPE_ON_DISCOVERY_REMOVE, json);
    }

};

static jfieldID getDsmFieldId(JNIEnv *env, jobject self) {
    if (env != nullptr && self != nullptr) {
        jclass clazz = env->GetObjectClass(self);
        if (clazz != nullptr) {
            jfieldID context = env->GetFieldID(clazz, "dsmFromNative", "J");
            return context;
        }
    }
    return nullptr;
}

static jmethodID getEventMethodId(JNIEnv *env, jobject self) {
    if (env != nullptr && self != nullptr) {
        jclass clazz = env->GetObjectClass(self);
        if (clazz != nullptr) {
            return env->GetMethodID(clazz, "onEventFromNative", "(ILjava/lang/String;)V");
        }
    }
    return nullptr;
}

static JniDsm *getJniDsm(JNIEnv *env, jobject self) {
    if (env != nullptr && self != nullptr) {
        jfieldID context = getDsmFieldId(env, self);
        if (context != nullptr) {
            jlong value = env->GetLongField(self, context);
            if (value != 0L) {
                JniDsm *dsm = (JniDsm *) value;
                return dsm;
            } else {
                return nullptr;
            }
        }
    }
    LOGE("[%s] Params is illegal", __func__);
    return nullptr;
}

static JniDsm *setJniDsm(JNIEnv *env, jobject self, long dsm) {
    JniDsm *old = getJniDsm(env, self);
    if (env != nullptr && self != nullptr) {
        env->SetLongField(self, getDsmFieldId(env, self), dsm);
    }
    return old;
}

void DSM_init(JNIEnv *env, jobject jobj, jobject self) {
    JniDsm *dsm = getJniDsm(env, self);
    if (dsm == nullptr) {
        dsm = new JniDsm();
        dsm->globalSelf = env->NewWeakGlobalRef(self);
        dsm->dsmFieldId = getDsmFieldId(env, self);
        if (dsm->dsmFieldId == nullptr) {
            LOGE("[%s] Context is null", __func__);
        }
        dsm->eventMethodId = getEventMethodId(env, self);
        if (dsm->eventMethodId == nullptr) {
            LOGE("[%s] Event is null", __func__);
        }
        setJniDsm(env, self, (long) dsm);
        LOGD("[%s] Initialized dsm=%ld", __func__, (long) dsm);
    } else {
        LOGD("[%s] No need to repeat initialization", __func__);
    }
}

void DSM_release(JNIEnv *env, jobject jobj, jobject self) {
    JniDsm *dsm = getJniDsm(env, self);
    if (dsm != nullptr) {
        env->DeleteWeakGlobalRef(dsm->globalSelf);
        dsm->globalSelf = nullptr;
        dsm->eventMethodId = nullptr;
        dsm->dsmFieldId = nullptr;
        setJniDsm(env, self, 0);
        delete dsm;
        dsm = nullptr;
        LOGD("[%s] Destroyed", __func__);
    } else {
        LOGD("[%s] No need to repeat destroy", __func__);
    }
}

void DSM_startDiscovery(JNIEnv *env, jobject jobj, jobject self, jint timeout) {
    JniDsm *jniDsm = getJniDsm(env, self);
    if (jniDsm != nullptr) {
        if (timeout >= 0) {
            int result = jniDsm->startDiscovery((unsigned int) (timeout));
            if (result == 0) {
                LOGD("[%s] Start discovering ...", __func__);
            } else {
                LOGE("[%s] Start discovery failure", __func__);
            }
        } else {
            LOGE("[%s] Timeout must be >= 0", __func__);
        }
    } else {
        LOGE("[%s] JniDsm is null, please initialize", __func__);
    }
}

void DSM_stopDiscovery(JNIEnv *env, jobject jobj, jobject self) {
    JniDsm *jniDsm = getJniDsm(env, self);
    if (jniDsm != nullptr) {
        int result = jniDsm->stopDiscovery();
        if (result == 0) {
            LOGD("[%s] Stop Discovery", __func__);
        } else {
            LOGE("[%s] Stop Discovery failure", __func__);
        }
    } else {
        LOGE("[%s] JniDsm is null, please initialize", __func__);
    }
}

jstring DSM_resolve(JNIEnv *env, jobject jobj, jobject self, jstring name_) {
    JniDsm *jniDsm = getJniDsm(env, self);
    if (jniDsm != nullptr) {
        const char *name = env->GetStringUTFChars(name_, 0);
        const char *result = jniDsm->resolve(name);
        if (result == nullptr) {
            LOGE("[%s] resolve failed name=%s result=%s", __func__, name, result);
            env->ReleaseStringUTFChars(name_, name);
            return env->NewStringUTF("");
        } else {
            env->ReleaseStringUTFChars(name_, name);
            return env->NewStringUTF(result);
        }
    }
    LOGE("[%s] JniDsm is null, please initialize", __func__);
    return env->NewStringUTF("");
}

jstring DSM_inverse(JNIEnv *env, jobject jobj, jobject self, jstring address_) {
    JniDsm *jniDsm = getJniDsm(env, self);
    if (jniDsm != nullptr) {
        const char *address = env->GetStringUTFChars(address_, 0);
        const char *result = jniDsm->inverse(address);
        if (result == nullptr) {
            LOGE("[%s] Inverse failed address=%s result=%s", __func__, address, result);
            env->ReleaseStringUTFChars(address_, address);
            return env->NewStringUTF("");
        } else {
            env->ReleaseStringUTFChars(address_, address);
            return env->NewStringUTF(result);
        }
    }
    LOGE("[%s] JniDsm is null, please initialize", __func__);
    return env->NewStringUTF("");
}

jint DSM_login(JNIEnv *env, jobject jobj, jobject self,
               jstring host_,
               jstring loginName_,
               jstring password_) {
    JniDsm *jniDsm = getJniDsm(env, self);
    if (jniDsm != nullptr) {
        const char *host = env->GetStringUTFChars(host_, 0);
        const char *loginName = env->GetStringUTFChars(loginName_, 0);
        const char *password = env->GetStringUTFChars(password_, 0);
        int result = jniDsm->login(host, loginName, password);
        env->ReleaseStringUTFChars(host_, host);
        env->ReleaseStringUTFChars(loginName_, loginName);
        env->ReleaseStringUTFChars(password_, password);
        return result;
    }
    LOGE("[%s] JniDsm is null", __func__);
    return DSM_ERROR;
}

jint DSM_logout(JNIEnv *env, jobject jobj, jobject self) {
    JniDsm *jniDsm = getJniDsm(env, self);
    if (jniDsm != nullptr) {
        int result = jniDsm->logout();
        return result;
    }
    LOGE("[%s] JniDsm is null, please initialize", __func__);
    return DSM_ERROR;
}

jstring DSM_shareGetListJson(JNIEnv *env, jobject jobj, jobject self) {
    JniDsm *jniDsm = getJniDsm(env, self);
    if (jniDsm != nullptr) {
        string *json = jniDsm->shareGetList();
        if (json == nullptr) {
            LOGE("[%s] Share get list failed", __func__);
            return env->NewStringUTF("");
        } else {
            jstring result = env->NewStringUTF(json->c_str());
            delete json;
            return result;
        }
    }
    LOGE("[%s] JniDsm is null, please initialize", __func__);
    return env->NewStringUTF("");
}

jint DSM_treeConnect(JNIEnv *env, jobject jobj, jobject self, jstring name_) {
    JniDsm *jniDsm = getJniDsm(env, self);
    if (jniDsm != nullptr) {
        const char *name = env->GetStringUTFChars(name_, 0);
        int tid = jniDsm->treeConnect(name);
        env->ReleaseStringUTFChars(name_, name);
        return tid;
    }
    LOGE("[%s] JniDsm is null, please initialize", __func__);
    return DSM_ERROR;
}

jint DSM_treeDisconnect(JNIEnv *env, jobject jobj, jobject self, jint tid_) {
    JniDsm *jniDsm = getJniDsm(env, self);
    if (jniDsm != nullptr) {
        return jniDsm->treeDisconnect(tid_);
    }
    LOGE("[%s] JniDsm is null, please initialize", __func__);
    return DSM_ERROR;
}

jstring DSM_find(JNIEnv *env, jobject jobj, jobject self,
                 jint tid,
                 jstring pattern_) {
    JniDsm *jniDsm = getJniDsm(env, self);
    if (jniDsm != nullptr) {
        const char *pattern = env->GetStringUTFChars(pattern_, 0);
        string *json = jniDsm->find(tid, pattern);
        if (json == nullptr) {
            LOGE("[%s] Find file list failed, pattern=%s", __func__, pattern);
            env->ReleaseStringUTFChars(pattern_, pattern);
            return env->NewStringUTF("");
        } else {
            env->ReleaseStringUTFChars(pattern_, pattern);
            jstring result = env->NewStringUTF(json->c_str());
            delete json;
            return result;
        }
    }
    LOGE("[%s] JniDsm is null, please initialize", __func__);
    return env->NewStringUTF("");
}

jstring DSM_fileStatus(JNIEnv *env, jobject jobj, jobject self,
                       jint tid_,
                       jstring path_) {
    JniDsm *jniDsm = getJniDsm(env, self);
    if (jniDsm != nullptr) {
        const char *path = env->GetStringUTFChars(path_, 0);
        string *json = jniDsm->fileStatus(tid_, path);
        if (json == nullptr) {
            LOGE("[%s] Query file status failed, path=%s", __func__, path);
            env->ReleaseStringUTFChars(path_, path);
            return env->NewStringUTF("");
        } else {
            env->ReleaseStringUTFChars(path_, path);
            jstring result = env->NewStringUTF(json->c_str());
            delete json;
            return result;
        }
    }
    LOGE("[%s] JniDsm is null, please initialize", __func__);
    return env->NewStringUTF("");
}

static const JNINativeMethod gMethods[] = {
        {"_init",             "(Ljava/lang/Object;)V",                                                       (void *) DSM_init},
        {"_release",          "(Ljava/lang/Object;)V",                                                       (void *) DSM_release},
        {"_startDiscovery",   "(Ljava/lang/Object;I)V",                                                      (void *) DSM_startDiscovery},
        {"_stopDiscovery",    "(Ljava/lang/Object;)V",                                                       (void *) DSM_stopDiscovery},
        {"_resolve",          "(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/String;",                    (void *) DSM_resolve},
        {"_inverse",          "(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/String;",                    (void *) DSM_inverse},
        {"_login",            "(Ljava/lang/Object;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)I", (void *) DSM_login},
        {"_logout",           "(Ljava/lang/Object;)I",                                                       (void *) DSM_logout},
        {"_shareGetListJson", "(Ljava/lang/Object;)Ljava/lang/String;",                                      (void *) DSM_shareGetListJson},
        {"_treeConnect",      "(Ljava/lang/Object;Ljava/lang/String;)I",                                     (void *) DSM_treeConnect},
        {"_treeDisconnect",   "(Ljava/lang/Object;I)I",                                                      (void *) DSM_treeDisconnect},
        {"_find",             "(Ljava/lang/Object;ILjava/lang/String;)Ljava/lang/String;",                   (void *) DSM_find},
        {"_fileStatus",       "(Ljava/lang/Object;ILjava/lang/String;)Ljava/lang/String;",                   (void *) DSM_fileStatus},
};

static int registerMediaPlayerMethod(JNIEnv *env) {
    int numMethods = (sizeof(gMethods) / sizeof((gMethods)[0]));
    jclass clazz = env->FindClass(CLASS_NAME);
    if (clazz == nullptr) {
        LOGE("[%s] Native registration unable to find class '%s'", __func__, CLASS_NAME);
        return JNI_ERR;
    }
    if (env->RegisterNatives(clazz, gMethods, numMethods) < 0) {
        LOGE("[%s] Native registration unable to find class '%s'", __func__, CLASS_NAME);
        return JNI_ERR;
    }
    env->DeleteLocalRef(clazz);
    return JNI_OK;
}

extern "C" JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM *vm, void *reserved) {
    javaVM = vm;
    JNIEnv *env;
    if (vm->GetEnv((void **) &env, JNI_VERSION_1_6) != JNI_OK) {
        return -1;
    }
    if (registerMediaPlayerMethod(env) != JNI_OK) {
        return -1;
    }
    return JNI_VERSION_1_4;
}
