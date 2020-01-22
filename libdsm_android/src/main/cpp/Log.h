#ifndef ANDROID_LIB_DSM_LOG_H
#define ANDROID_LIB_DSM_LOG_H

#include <android/log.h>

#define LOGD(...) ((void)__android_log_print(ANDROID_LOG_DEBUG, "[DSM][NATIVE]", __VA_ARGS__))
#define LOGE(...) ((void)__android_log_print(ANDROID_LOG_ERROR, "[DSM][NATIVE]", __VA_ARGS__))

#endif
