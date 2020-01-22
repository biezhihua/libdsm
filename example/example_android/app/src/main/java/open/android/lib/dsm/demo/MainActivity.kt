package open.android.lib.dsm.demo

import android.annotation.SuppressLint
import android.os.Bundle
import android.util.Log
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import open.android.lib.dsm.Dsm


@SuppressLint("SetTextI18n")
class MainActivity : AppCompatActivity() {

    var dsm = Dsm()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        dsm.discoveryListener = object : Dsm.DiscoveryListener {

            override fun onEntryAdded(json: String) {
                Log.d(TAG, "onEntryAdded() called with: json = [$json]")
            }

            override fun onEntryRemoved(json: String) {
                Log.d(TAG, "onEntryRemoved() called with: json = [$json]")
            }

        }
    }

    fun startDiscovery(view: View) {
        dsm.startDiscovery()
    }

    fun stopDiscovery(view: View) {
        dsm.stopDiscovery()
    }

    fun init(view: View) {
        dsm.init()
    }

    fun destroy(view: View) {
        dsm.release()
    }

    companion object {
        private val TAG = "[DSM][MAIN]"
    }

    fun logout(view: View) {
        Log.d(TAG, "logout() called with: result = [${dsm.logout()}]")
    }

    fun login(view: View) {
        Log.d(
            TAG, "login() called with: name = [SMBSHARE] result = [${dsm.login(
                "BIEZHIHUA-PC",
                "test",
                "test"
            )}]"
        )
    }

    fun shareList(view: View) {
        Log.d(TAG, "shareList() called with: result = [${dsm.getShareList()}]")
    }

    var tid: Int = 0

    fun connect(view: View) {
        tid = dsm.treeConnect("F")
        Log.d(TAG, "connect() called with: result = [$tid]")
    }

    fun disconnect(view: View) {
        val result = dsm.treeDisconnect(tid)
        tid = 0
        Log.d(TAG, "disconnect() called with: result = [$result]")
    }

    fun find(view: View) {
        Log.d(TAG, "find() called with: result = [${dsm.find(tid, "\\*")}]")
    }

    fun openDir(view: View) {
        Log.d(TAG, "openDir() called with: result = [${dsm.find(tid, "\\splayer\\*")}]")

        Log.d(
            TAG,
            "openDir() called with: result = [${dsm.find(tid, "\\splayer\\splayer_soundtouch\\*")}]"
        )
    }

    fun fileStatus(view: View) {
        Log.d(
            TAG,
            "fileStatus() called with: result = [${dsm.fileStatus(
                tid,
                "\\splayer\\splayer_soundtouch\\Test.cpp"
            )}]"
        )
    }
}
