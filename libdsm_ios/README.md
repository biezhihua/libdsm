# Introduction

An iOS wrapper for the libdsm library


# Dependence Library

* C++ Json Library : https://github.com/nlohmann/json
* Plain'OI C Defective SMB Library  : https://videolabs.github.io/libdsm/

# Example the function

```

func initOrRelase() {
    let dsm = Dsm()
    dsm.dsmInit()
    dsm.dsmRelease()
}

struct MyDiscoveryListener : DiscoveryListener {
    
    func onEntryAdded(json: String) {
        Log.d("Main", "onEntryAdded \(json)")
    }
    
    func onEntryRemoved(json: String) {
        Log.d("Main", "onEntryRemoved \(json)")
    }
    
}

func discoverySmbServer() {
    let dsm = Dsm()
    dsm.dsmInit()

    dsm.discoveryListener = MyDiscoveryListener()
    
    dsm.startDiscovery()
    dsm.stopDiscovery()

    dsm.dsmRelease()
}

func loginOrlogoutSmbServer() {
    let dsm = Dsm()
    dsm.dsmInit()

    dsm.login("xxx-pc", "account-name", "password")

    dsm.logout()

    dsm.dsmRelease()()
}

func getSmbServerShareList() {
    let dsm = Dsm()
    dsm.dsmInit()

    dsm.login("xxx-pc", "account-name", "password")

    let shareJson = dsm.getShareList()

    dsm.logout()

    dsm.dsmRelease()
}

func connectToSmbServerShare() {
    let dsm = Dsm()
    dsm.dsmInit()

    dsm.login("xxx-pc", "account-name", "password")

    let shareNamesJson = dsm.getShareList()

    let tid = dsm.treeConnect("share-name")

    dsm.treeDisconnect(tid)

    dsm.logout()

    dsm.dsmRelease()
}

func findRootFilesFromSmbServer() {
    let dsm = Dsm()
    dsm.dsmInit()

    dsm.login("xxx-pc", "account-name", "password")

    let shareNamesJson = dsm.getShareList()

    let tid = dsm.treeConnect("share-name")

    let filesJson = dsm.find(tid, "\\*")

    dsm.treeDisconnect(tid)

    dsm.logout()

    dsm.dsmRelease()
}

func findDirectoryFilesFromSmbServer() {
    let dsm = Dsm()
    dsm.dsmInit()

    dsm.login("xxx-pc", "account-name", "password")

    let shareNamesJson = dsm.getShareList()

    let tid = dsm.treeConnect("share-name")

    let filesJson = dsm.find(tid, "\\Directory\\*")

    dsm.treeDisconnect(tid)

    dsm.logout()

    dsm.dsmRelease()
}

func queryFileStatusFromSmbServer() {
    let dsm = Dsm()
    dsm.dsmInit()

    dsm.login("xxx-pc", "account-name", "password")

    let shareNamesJson = dsm.getShareList()

    let tid = dsm.treeConnect("share-name")

    let fileStatusJson = dsm.fileStatus(tid, "\\Directory\\Directory\\File.Extension")

    dsm.treeDisconnect(tid)

    dsm.logout()

    dsm.dsmRelease()
}

```