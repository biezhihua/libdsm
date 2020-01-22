# Introduction

[![Build Status](https://api.travis-ci.org/biezhihua/android_libdsm.svg?branch=master)](https://travis-ci.org/biezhihua/android_libdsm)
[![License](https://img.shields.io/badge/license-GPL-blue)](https://github.com/biezhihua/android_libdsm/blob/master/LICENSE)
[![Version](https://img.shields.io/github/v/release/biezhihua/android_libdsm)](https://github.com/biezhihua/android_libdsm/releases)

An Unity(Android) wrapper for the libdsm library


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


# License

```
MIT License

Copyright (c) 2020 unity-libdsm

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