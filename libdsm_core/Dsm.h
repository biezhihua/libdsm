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

    int startDiscovery(unsigned int timeout = 4);

    int stopDiscovery();

    const char *resolve(const char *name);

    const char *inverse(const char *address);

    int login(const char *host, const char *loginName, const char *password);

    int logout();

    string *shareGetList();

    int treeConnect(const char *name);

    int treeDisconnect(int tid);

    string *find(int tid, const char *regex);

    string *fileStatus(int tid, const char *path);

    virtual void onDiscoveryEntryAdded(const char *json) = 0;

    virtual void onDiscoveryEntryRemoved(const char *json) = 0;
};


#endif
