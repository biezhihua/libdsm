package open.android.lib.libdsm

import open.android.lib.dsm.Dsm


class Example {

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
}
