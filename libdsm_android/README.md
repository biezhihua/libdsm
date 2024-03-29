# Introduction

[![Build Status](https://api.travis-ci.org/biezhihua/android_libdsm.svg?branch=master)](https://travis-ci.org/biezhihua/android_libdsm)
[![License](https://img.shields.io/badge/license-GPL-blue)](https://github.com/biezhihua/android_libdsm/blob/master/LICENSE)
[![Version](https://img.shields.io/github/v/release/biezhihua/android_libdsm)](https://github.com/biezhihua/android_libdsm/releases)

An Android(Kotlin) wrapper for the libdsm library


```
compile 'open.android.lib.dsm:libdsm:1.1.9'
```

# Dependence Library

* C++ Json Library : https://github.com/nlohmann/json
* Plain'OI C Defective SMB Library  : https://videolabs.github.io/libdsm/

# Example the function

```
fun initOrRelase() {
    val dsm = Dsm()
    dsm.init()
    dsm.release()
}

fun discoverySmbServer() {
    val dsm = Dsm()
    dsm.init()

    dsm.discoveryListener = object : Dsm.DiscoveryListener {
        override fun onEntryAdded(json: String) {
        }

        override fun onEntryRemoved(json: String) {
        }

    }
    dsm.startDiscovery()
    dsm.stopDiscovery()

    dsm.release()
}

fun loginOrlogoutSmbServer() {
    val dsm = Dsm()
    dsm.init()

    dsm.login("xxx-pc", "account-name", "password")

    dsm.logout()

    dsm.release()
}

fun getSmbServerShareList() {
    val dsm = Dsm()
    dsm.init()

    dsm.login("xxx-pc", "account-name", "password")

    val shareJson = dsm.getShareList()

    dsm.logout()

    dsm.release()
}

fun connectToSmbServerShare() {
    val dsm = Dsm()
    dsm.init()

    dsm.login("xxx-pc", "account-name", "password")

    val shareNamesJson = dsm.getShareList()

    val tid = dsm.treeConnect("share-name")

    dsm.treeDisconnect(tid)

    dsm.logout()

    dsm.release()
}

fun findRootFilesFromSmbServer() {
    val dsm = Dsm()
    dsm.init()

    dsm.login("xxx-pc", "account-name", "password")

    val shareNamesJson = dsm.getShareList()

    val tid = dsm.treeConnect("share-name")

    val filesJson = dsm.find(tid, "\\*")

    dsm.treeDisconnect(tid)

    dsm.logout()

    dsm.release()
}

fun findDirectoryFilesFromSmbServer() {
    val dsm = Dsm()
    dsm.init()

    dsm.login("xxx-pc", "account-name", "password")

    val shareNamesJson = dsm.getShareList()

    val tid = dsm.treeConnect("share-name")

    val filesJson = dsm.find(tid, "\\Directory\\*")

    dsm.treeDisconnect(tid)

    dsm.logout()

    dsm.release()
}

fun queryFileStatusFromSmbServer() {
    val dsm = Dsm()
    dsm.init()

    dsm.login("xxx-pc", "account-name", "password")

    val shareNamesJson = dsm.getShareList()

    val tid = dsm.treeConnect("share-name")

    val fileStatusJson = dsm.fileStatus(tid, "\\Directory\\Directory\\File.Extension")

    dsm.treeDisconnect(tid)

    dsm.logout()

    dsm.release()
}
```

# Other
- https://developer.android.com/training/articles/perf-jni?hl=zh_cn