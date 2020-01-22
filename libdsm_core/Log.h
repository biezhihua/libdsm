#ifndef CORE_LOG_H
#define CORE_LOG_H

#ifdef __ANDROID__

#include <android/log.h>

#define _LOGD(...) ((void)__android_log_print(ANDROID_LOG_DEBUG, "[DSM][NATIVE]", __VA_ARGS__))
#define _LOGE(...) ((void)__android_log_print(ANDROID_LOG_ERROR, "[DSM][NATIVE]", __VA_ARGS__))

#elif __APPLE__

#include <sys/syslog.h>

#define _LOGD(...) (void)syslog(LOG_DEBUG, __VA_ARGS__);
#define _LOGE(...) (void)syslog(LOG_ERR,__VA_ARGS__);

#else

#define _LOGD(...) (void)printf(__VA_ARGS__);
#define _LOGE(...) (void)printf(__VA_ARGS__);

#endif

#define LOGD(...) _LOGD(__VA_ARGS__)
#define LOGE(...) _LOGE(__VA_ARGS__)

#endif
