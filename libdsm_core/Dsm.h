#ifndef CORE_LIB_DSM_H
#define CORE_LIB_DSM_H

#include <string>
#include <cstdlib>
#include <cstdio>
#include <cstring>
#include <cassert>
#include "nlohmann/json.h"
#include <arpa/inet.h>

using json = nlohmann::json;

extern "C" {
#include "Log.h"
#include "bdsm/bdsm.h"
};

#define DSM_ERROR              -100

using namespace std;

class Dsm {

private:

    netbios_ns *discoveryNS = nullptr;
    netbios_ns *loginNS = nullptr;
    smb_session *session = nullptr;
    string *host = nullptr;
    string *loginName = nullptr;
    string *password = nullptr;

public:

    Dsm();

    ~Dsm();

    /**
     * 开始发现SMB服务器
     */
    int startDiscovery(unsigned int timeout = 4);

    /**
     * 停止发现SMB服务器
     */
    int stopDiscovery();

    /**
     * 解析SMB服务器名字为地址
     */
    const char *resolve(const char *name);

    /**
     * 解析SMB服务器地址为名字
     */
    const char *inverse(const char *address);

    /**
     * 登录SMB服务器
     */
    int login(const char *host, const char *loginName, const char *password);

    /**
     * 登出SMB服务器
     */
    int logout();

    /**
     * 获取SMB服务器中共享的列表数据
     */
    string *shareGetList();

    /**
     * 连接到共享目录
     */
    int treeConnect(const char *name);

    /**
     * 断开共享目录
     */
    int treeDisconnect(int tid);

    /**
     * 获取符合regex规则的文件
     */
    string *find(int tid, const char *regex);

    /**
     * 获取符合regex规则的文件状态
     */
    string *fileStatus(int tid, const char *path);

    /**
     * 当SMB服务器被发现时回调
     */
    virtual void onDiscoveryEntryAdded(const char *json) = 0;

    /**
     * 当SMB服务器不可用时回调
     */
    virtual void onDiscoveryEntryRemoved(const char *json) = 0;
};


#endif
