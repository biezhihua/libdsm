#include "Dsm.h"

Dsm::Dsm() {
    discoveryNS = nullptr;
    loginNS = nullptr;
    session = nullptr;
    host = nullptr;
    loginName = nullptr;
    password = nullptr;
}

Dsm::~Dsm() {
    stopDiscovery();
    logout();
}

static void on_entry_added(void *p_opaque, netbios_ns_entry *entry) {
    if (p_opaque != nullptr) {
        Dsm *dsm = (Dsm *) p_opaque;

        struct in_addr addr{};
        addr.s_addr = netbios_ns_entry_ip(entry);

        const char *address = inet_ntoa(addr);
        const char *group = netbios_ns_entry_group(entry);
        const char *name = netbios_ns_entry_name(entry);
        const int type = netbios_ns_entry_type(entry);

        json entryJson;
        entryJson["address"] = address;
        entryJson["group"] = group;
        entryJson["name"] = name;
        entryJson["type"] = type;
        std::string json = entryJson.dump();
        const char *jsonC = json.c_str();

        dsm->onDiscoveryEntryAdded(jsonC);
    }
}

static void on_entry_removed(void *p_opaque, netbios_ns_entry *entry) {
    if (p_opaque != nullptr) {
        Dsm *dsm = (Dsm *) p_opaque;

        struct in_addr addr{};
        addr.s_addr = netbios_ns_entry_ip(entry);

        const char *address = inet_ntoa(addr);
        const char *group = netbios_ns_entry_group(entry);
        const char *name = netbios_ns_entry_name(entry);
        const int type = netbios_ns_entry_type(entry);

        json entryJson;
        entryJson["address"] = address;
        entryJson["group"] = group;
        entryJson["name"] = name;
        entryJson["type"] = type;
        std::string json = entryJson.dump();
        const char *jsonC = json.c_str();

        dsm->onDiscoveryEntryRemoved(jsonC);
    }
}

int Dsm::startDiscovery(unsigned int timeout) {
    if (discoveryNS == nullptr) {
        discoveryNS = netbios_ns_new();
        if (discoveryNS != nullptr) {
            netbios_ns_discover_callbacks callbacks;
            callbacks.p_opaque = this;
            callbacks.pf_on_entry_added = on_entry_added;
            callbacks.pf_on_entry_removed = on_entry_removed;
            if (netbios_ns_discover_start(discoveryNS, timeout, &callbacks) == -1) {
                return DSM_ERROR;
            }
            return DSM_SUCCESS;
        }
    }
    return DSM_ERROR;
}

int Dsm::stopDiscovery() {
    if (discoveryNS != nullptr) {
        netbios_ns_discover_stop(discoveryNS);
        netbios_ns_destroy(discoveryNS);
        discoveryNS = nullptr;
        return DSM_SUCCESS;
    }
    return DSM_ERROR;
}

const char *Dsm::resolve(const char *name) {
    if (name == nullptr) {
        LOGE("[%s] Params is illegal", __func__);
        return nullptr;
    }
    netbios_ns *ns;
    struct in_addr address{};
    ns = netbios_ns_new();
    if (netbios_ns_resolve(ns, name, NETBIOS_FILESERVER, &address.s_addr)) {
        LOGE("[%s] Unable to perform name resolution for %s ", __func__, name);
        return nullptr;
    }
    if (!address.s_addr) {
        LOGE("[%s] Unable to perform name resolution for %s ", __func__, name);
        return nullptr;
    }
    netbios_ns_destroy(ns);
    return inet_ntoa(address);
}

const char *Dsm::inverse(const char *address) {
    if (address == nullptr) {
        LOGE("[%s] Params is illegal", __func__);
        return nullptr;
    }
    netbios_ns *ns;
    struct in_addr addr;
    const char *name;
    ns = netbios_ns_new();
    inet_pton(AF_INET, address, &addr);
    if ((name = netbios_ns_inverse(ns, addr.s_addr)) == NULL) {
        LOGE("[%s] Unable to perform inverse name resolution for %s", __func__, address);
        return nullptr;
    }
    netbios_ns_destroy(ns);
    return name;
}

int Dsm::login(const char *host, const char *loginName, const char *password) {
    if (host == nullptr || loginName == nullptr || password == nullptr) {
        LOGE("[%s] Params invalid host=%s loginName=%s password=%s", __func__, host, loginName,
                password);
        return DSM_ERROR;
    }
    if (loginNS != nullptr && session != nullptr) {
        LOGE("[%s] Already login host=%s", __func__, host);
        return DSM_ERROR;
    }
    loginNS = netbios_ns_new();
    session = smb_session_new();
    struct sockaddr_in addr{};
    if (netbios_ns_resolve(loginNS, host, NETBIOS_FILESERVER, &addr.sin_addr.s_addr)) {
        LOGE("[%s] Unable to perform name resolution for %s ", __func__, host);
        smb_session_destroy(session);
        netbios_ns_destroy(loginNS);
        session = nullptr;
        return DSM_ERROR;
    }
    if (smb_session_connect(session,
            host, addr.sin_addr.s_addr, SMB_TRANSPORT_TCP) == DSM_SUCCESS) {
        LOGD("[%s] Successfully connected to %s ", __func__, host);
    } else {
        LOGD("[%s] Unable to connect to %s ", __func__, host);
        smb_session_destroy(session);
        netbios_ns_destroy(loginNS);
        session = nullptr;
        return DSM_ERROR;
    }
    smb_session_set_creds(session, host, loginName, password);
    if (smb_session_login(session) == DSM_SUCCESS) {
        if (smb_session_is_guest(session)) {
            LOGD("[%s] Login failed but we were logged in as GUEST", __func__);
        } else {
            LOGD("[%s] Successfully logged in as host=%s login=%s", __func__, host, loginName);
        }
        Dsm::host = new string(host);
        Dsm::loginName = new string(loginName);
        Dsm::password = new string(password);
        return DSM_SUCCESS;
    } else {
        smb_session_destroy(session);
        netbios_ns_destroy(loginNS);
        session = nullptr;
        return DSM_ERROR;
    }
}

int Dsm::logout() {
    if (loginNS == nullptr || session == nullptr) {
        LOGE("[%s] Already Logout", __func__);
        Dsm::host = nullptr;
        Dsm::loginName = nullptr;
        Dsm::password = nullptr;
        loginNS = nullptr;
        session = nullptr;
        return DSM_ERROR;
    }
    smb_session_logoff(session);
    smb_session_destroy(session);
    session = nullptr;
    netbios_ns_destroy(loginNS);
    loginNS = nullptr;
    delete Dsm::host;
    delete Dsm::loginName;
    delete Dsm::password;
    return DSM_SUCCESS;
}

string *Dsm::shareGetList() {
    if (loginNS == nullptr || session == nullptr) {
        LOGE("[%s] Please login", __func__);
        return nullptr;
    }
    char **share_list;
    if (smb_share_get_list(session, &share_list, NULL) != DSM_SUCCESS) {
        LOGE("[%s] Unable to list share for %s", __func__, host->c_str());
        return nullptr;
    }
    json result;
    json data = json::array();
    for (size_t j = 0; share_list[j] != NULL; j++) {
        data.push_back(share_list[j]);
    }
    result["data"] = data;
    smb_share_list_destroy(share_list);
    return new string(result.dump().c_str());
}

int Dsm::treeConnect(const char *name) {
    if (loginNS == nullptr || session == nullptr) {
        LOGE("[%s] Please login", __func__);
        return DSM_ERROR;
    }
    if (name == nullptr) {
        LOGE("[%s] Params is illegal", __func__);
        return DSM_ERROR;
    }
    smb_tid tid;
    int ret = smb_tree_connect(session, name, &tid);
    if (ret != DSM_SUCCESS) {
        LOGE("[%s] Unable to connect to name=%s ret=%d", __func__, name, ret);
        return DSM_ERROR;
    }
    return tid;
}

int Dsm::treeDisconnect(int tid) {
    if (loginNS == nullptr || session == nullptr) {
        LOGE("[%s] Please login", __func__);
        return DSM_ERROR;
    }
    smb_tid smbTid = (smb_tid) (tid);
    if (smb_tree_disconnect(session, smbTid) != DSM_SUCCESS) {
        LOGE("[%s] Disconnect a share fail", __func__);
        return DSM_ERROR;
    }
    return DSM_SUCCESS;
}

string *Dsm::find(int tid, const char *pattern) {
    if (tid == 0) {
        LOGE("[%s] Tid is illegal", __func__);
        return nullptr;
    }
    if (pattern == nullptr) {
        LOGE("[%s] Pattern is illegal", __func__);
        return nullptr;
    }
    if (loginNS == nullptr || session == nullptr) {
        LOGE("[%s] Please login", __func__);
        return nullptr;
    }
    smb_tid smbTid = (smb_tid) (tid);
    smb_file *files = smb_find(session, smbTid, pattern);
    if (files == nullptr) {
        LOGE("[%s] find file failed", __func__);
        return nullptr;
    }
    size_t filesCount = smb_stat_list_count(files);
    if (filesCount <= 0) {
        LOGE("[%s] file count invalid", __func__);
        return nullptr;
    }

    json result;
    json data = json::array();

    for (size_t i = 0; i < filesCount; i++) {
        smb_stat st = smb_stat_list_at(files, i);
        if (st == NULL) {
            LOGE("[%s] smb_stat_list_at failed", __func__);
            break;
        }
        json file;
        file["name"] = smb_stat_name(st);
        file["is_dir"] = (smb_stat_get(st, SMB_STAT_ISDIR) != 0 ? 1 : 0);
        file["size"] = smb_stat_get(st, SMB_STAT_SIZE);
        data.push_back(file);
    }

    smb_stat_list_destroy(files);

    result["data"] = data;
    return new string(result.dump().c_str());
}

string *Dsm::fileStatus(int tid, const char *path) {
    if (loginNS == nullptr || session == nullptr) {
        LOGE("[%s] Please login", __func__);
        return nullptr;
    }
    if (tid < 0) {
        LOGE("[%s] Tid is illegal", __func__);
        return nullptr;
    }
    if (path == nullptr) {
        LOGE("[%s] Path is illegal", __func__);
        return nullptr;
    }
    smb_tid smbTid = (smb_tid) (tid);
    smb_stat stat = smb_fstat(session, smbTid, path);

    json result;
    json data = json::array();

    json file;
    file["name"] = smb_stat_name(stat);
    file["is_dir"] = (smb_stat_get(stat, SMB_STAT_ISDIR) != 0 ? 1 : 0);
    file["size"] = smb_stat_get(stat, SMB_STAT_SIZE);
    data.push_back(file);
    smb_stat_destroy(stat);

    result["data"] = data;
    return new string(result.dump().c_str());
}




