@file:Suppress("FunctionName", "SpellCheckingInspection")

package open.android.lib.dsm

import android.os.Handler
import android.os.Looper
import android.util.Log
import com.alibaba.fastjson.JSONObject
import open.android.lib.dsm.annotations.AccessedByNative
import open.android.lib.dsm.annotations.CalledByNative

/**
 * An Android wrapper for the libdsm library。
 * https://videolabs.github.io/libdsm/
 */
class Dsm {

    /**
     * SMB server listens to callbacks.
     */
    interface DiscoveryListener {
        fun onEntryAdded(json: JSONObject)
        fun onEntryRemoved(json: JSONObject)
    }

    /**
     * Used to callback messages to the main thread
     */
    private val handler = Handler(Looper.getMainLooper())

    /**
     * Bind to an instance of a C ++ DSM class
     */
    @AccessedByNative
    val dsmFromNative: Long = 0L

    var discoveryListener: DiscoveryListener? = null

    init {
        // Auto init
        init()
    }

    /**
     * Initialize the library, set environment variables, and bind C ++ object to Java object.
     */
    fun init() {
        _init(this)
    }

    /**
     * Release the library and unbind the binding relationship, otherwise it may cause a memory leak.
     */
    fun release() {
        _release(this)
    }

    /**
     * Start to discover the SMB server in the local area network.
     * When any SMB server is found or when the SMB server is disappears, a callback notification will be generated.
     */
    fun startDiscovery(timeOut: Int = 4) {
        _startDiscovery(this, timeOut)
    }

    /**
     * Stop discovering SMB servers in the LAN.
     */
    fun stopDiscovery() {
        _stopDiscovery(this)
    }

    /**
     * Used to distribute different types of messages to the main thread.
     */
    @CalledByNative
    fun onEventFromNative(what: Int, json: String) {
        // FIX: Chinese identification error
        val newJson = JSONObject.parseObject(json)
        when (what) {
            EventType.DISCOVERY_ADD.value -> {
                handler.post {

                    discoveryListener?.onEntryAdded(newJson)
                }
            }
            EventType.DISCOVERY_REMOVE.value -> {
                handler.post {
                    discoveryListener?.onEntryRemoved(newJson)
                }
            }
            else -> {
            }
        }
    }

    /**
     * Resolve a Netbios name
     *
     * This function tries to resolves the given NetBIOS name with the
     * given type on the LAN, using broadcast queries. No WINS server is called.
     */
    fun resolve(name: String): String {
        return _resolve(this, name)
    }

    /**
     * Perform an inverse netbios resolve (get name from ip)
     *
     * This function does a NBSTAT and stores all the returned entry in
     * the internal list of entries. It returns one of the name found. (Normally
     * the <20> or <0> name)
     */
    fun inverse(address: String): String {
        return _inverse(this, address)
    }

    /**
     * Login to an SMB server, if login fails, it will try to log in again with Gust identity.
     */
    fun login(hostName: String, loginName: String, password: String): Int {
        return _login(this, hostName, loginName, password)
    }

    /**
     * Exit from an SMB server.
     *
     * @return 0 = SUCCESS OR ERROR
     */
    fun logout(): Int {
        return _logout(this)
    }

    /**
     * List the existing share of this sessions's machine
     *
     * This function makes a RPC to the machine this session is currently
     * authenticated to and list all the existing shares of this machines. The share
     * starting with a $ are supposed to be system/hidden share.
     *
     * @return An a json list.
     */
    fun getShareList(): JSONObject? {
        val result = _shareGetListJson(this)
        return JSONObject.parseObject(result)
    }

    /**
     * Connects to a SMB share
     *
     * Before being able to list/read files on a SMB file server, you have
     * to be connected to the share containing the files you want to read or
     * the directories you want to list
     *
     * @param name The share name @see smb_share_list
     * @return tid
     */
    fun treeConnect(name: String): Int {
        return _treeConnect(this, name)
    }

    /**
     * Disconnect from a share
     *
     * @return 0 on success or a DSM error code in case of error
     */
    fun treeDisconnect(tid: Int): Int {
        return _treeDisconnect(this, tid)
    }

    /**
     * Returns infos about files matching a pattern
     *
     * This functions uses the FIND_FIRST2 SMB operations to list files
     * matching a certain pattern. It's basically used to list folder contents
     *
     * @param pattern The pattern to match files. '\\*' will list all the files at
     * the root of the share. '\\afolder\\*' will list all the files inside of the
     * 'afolder' directory.
     *
     * @return An json list of files.
     */
    fun find(tid: Int, pattern: String): JSONObject? {
        val result = _find(this, tid, pattern)
        return JSONObject.parseObject(result)
    }

    /**
     * Get the status of a file from it's path inside of a share
     *
     * @param path The full path of the file relative to the root of the share
     * (e.g. '\\folder\\file.ext')
     *
     * @return An opaque smb_stat or NULL in case of error. You need to
     * destory this object with smb_stat_destroy after usage.
     */
    fun fileStatus(tid: Int, path: String): JSONObject? {
        val result = _fileStatus(this, tid, path)
        return JSONObject.parseObject(result)
    }

    protected fun finalize() {
        Log.d(TAG, "finalize() called")
    }

    private external fun _init(self: Any)

    private external fun _release(self: Any)

    private external fun _startDiscovery(self: Any, timeOut: Int)

    private external fun _stopDiscovery(self: Any)

    private external fun _resolve(self: Any, name: String): String

    private external fun _inverse(self: Any, address: String): String

    private external fun _login(self: Any, host: String, loginName: String, password: String): Int

    private external fun _logout(self: Any): Int

    private external fun _shareGetListJson(self: Any): String

    private external fun _treeConnect(self: Any, name: String): Int

    private external fun _treeDisconnect(self: Any, tid: Int): Int

    private external fun _find(self: Any, tid: Int, pattern: String): String

    private external fun _fileStatus(self: Any, tid: Int, pat: String): String

    companion object {

        private const val TAG = "[DSM][KOTLIN]"

        // static init
        init {
            System.loadLibrary("open_dsm")
        }

        enum class EventType(val value: Int) {
            DISCOVERY_ADD(0),
            DISCOVERY_REMOVE(1),
        }

        enum class ReturnType(val value: Int) {
            DSM_SUCCESS(0),
            DSM_ERROR(-100),
        }
    }

}