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


# License

```
MIT License

Copyright (c) 2020 ios-libdsm

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```