package open.flutter.libdsm

import android.annotation.SuppressLint
import android.os.AsyncTask
import android.util.Log
import androidx.annotation.NonNull
import com.alibaba.fastjson.JSONObject
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import open.android.lib.dsm.Dsm
import java.util.*


/** DsmPlugin */
open class DsmPlugin : FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {

    private val TAG = "DsmPlugin"

    private val dsmCache = mutableMapOf<String, Dsm>()

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        val dsmPlugin = DsmPlugin()

        val methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "open.flutter/libdsm")
        val eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "open.flutter/discovery_listener")
        methodChannel.setMethodCallHandler(dsmPlugin)
        eventChannel.setStreamHandler(dsmPlugin)
    }

    // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
    // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
    // depending on the user's project. onAttachedToEngine or registerWith must both be defined
    // in the same class.
    companion object {

        const val ID = "id"
        const val TIME_OUT = "time_out"
        const val NAME = "name"
        const val ADDRESS = "address"
        const val HOST = "host"
        const val LOGIN_NAME = "login_name"
        const val PASSWORD = "password"
        const val TID = "tid"
        const val PATTERN = "pattern"
        const val PATH = "path"
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        Log.i(TAG, "onMethodCall() called with: call.method = [${call.method}], call.args = [${call.arguments}]")
        when (call.method) {
            "DSM_init" -> {
                val dsm = Dsm()
                val dsmId = UUID.randomUUID().toString()
                dsmCache[dsmId] = dsm
                result.success(dsmId)
            }
            "DSM_release" -> {
                if (call.arguments == null || call.argument<String>(ID).isNullOrEmpty()) {
                    result.error("PARAM_ERROR", "Illegal parameter", null)
                } else {
                    val dsmId = call.argument<String>(ID)!!
                    val dsm = dsmCache[dsmId]!!
                    dsmCache.remove(dsmId)
                    dsm.release()
                    result.success(null)
                }

            }
            "DSM_start_discovery" -> {
                if (call.arguments == null || call.argument<String>(ID).isNullOrEmpty()) {
                    result.error("PARAM_ERROR", "Illegal parameter", null)
                } else {
                    val dsmId = call.argument<String>(ID)!!
                    val timeOut = call.argument<Int>(TIME_OUT)
                    val dsm = dsmCache[dsmId]!!
                    dsm.startDiscovery(timeOut ?: 4)
                    result.success(null)
                }
            }
            "DSM_stop_discovery" -> {
                if (call.arguments == null || call.argument<String>(ID).isNullOrEmpty()) {
                    result.error("PARAM_ERROR", "Illegal parameter", null)
                } else {
                    val dsmId = call.argument<String>(ID)!!
                    val dsm = dsmCache[dsmId]!!
                    dsm.stopDiscovery()
                    result.success(null)
                }
            }
            "DSM_resolve" -> {
                if (call.arguments == null || call.argument<String>(ID).isNullOrEmpty() || call.argument<String>(NAME).isNullOrEmpty()) {
                    result.error("PARAM_ERROR", "Illegal parameter", null)
                } else {
                    val dsmId = call.argument<String>(ID)!!
                    val name = call.argument<String>(NAME)!!
                    val dsm = dsmCache[dsmId]!!

                    @SuppressLint("StaticFieldLeak")
                    val task = object : AsyncTask<Void?, Void?, Any?>() {
                        override fun doInBackground(vararg params: Void?): Any {
                            return dsm.resolve(name)
                        }

                        override fun onPostExecute(address: Any?) {
                            super.onPostExecute(address)
                            result.success(address)
                        }
                    }
                    task.execute()

                }
            }
            "DSM_inverse" -> {
                if (call.arguments == null || call.argument<String>(ID).isNullOrEmpty() || call.argument<String>(ADDRESS).isNullOrEmpty()) {
                    result.error("PARAM_ERROR", "Illegal parameter", null)
                } else {
                    val dsmId = call.argument<String>(ID)!!
                    val address = call.argument<String>(ADDRESS)!!
                    val dsm = dsmCache[dsmId]!!

                    @SuppressLint("StaticFieldLeak")
                    val task = object : AsyncTask<Void?, Void?, Any?>() {
                        override fun doInBackground(vararg params: Void?): Any {
                            return dsm.inverse(address)
                        }

                        override fun onPostExecute(name: Any?) {
                            super.onPostExecute(name)
                            result.success(name)
                        }

                    }
                    task.execute()
                }
            }
            "DSM_login" -> {
                if (call.arguments == null ||
                        call.argument<String>(ID).isNullOrEmpty() ||
                        call.argument<String>(HOST).isNullOrEmpty() ||
                        call.argument<String>(LOGIN_NAME).isNullOrEmpty() ||
                        call.argument<String>(PASSWORD).isNullOrEmpty()
                ) {
                    result.error("PARAM_ERROR", "Illegal parameter", null)
                } else {
                    val dsmId = call.argument<String>(ID)!!
                    val host = call.argument<String>(HOST)!!
                    val loginName = call.argument<String>(LOGIN_NAME)!!
                    val password = call.argument<String>(PASSWORD)!!
                    val dsm = dsmCache[dsmId]!!

                    @SuppressLint("StaticFieldLeak")
                    val task = object : AsyncTask<Void?, Void?, Any?>() {
                        override fun doInBackground(vararg params: Void?): Any {
                            return dsm.login(host, loginName, password)
                        }

                        override fun onPostExecute(loginResult: Any?) {
                            super.onPostExecute(loginResult)
                            result.success(loginResult)
                        }

                    }
                    task.execute()
                }
            }
            "DSM_logout" -> {
                if (call.arguments == null || call.argument<String>(ID).isNullOrEmpty()) {
                    result.error("PARAM_ERROR", "Illegal parameter", null)
                } else {
                    val dsmId = call.argument<String>(ID)!!
                    val dsm = dsmCache[dsmId]!!

                    @SuppressLint("StaticFieldLeak")
                    val task = object : AsyncTask<Void?, Void?, Any?>() {
                        override fun doInBackground(vararg params: Void?): Any {
                            return dsm.logout()
                        }

                        override fun onPostExecute(logoutResult: Any?) {
                            super.onPostExecute(logoutResult)
                            result.success(logoutResult)
                        }

                    }
                    task.execute()
                }
            }
            "DSM_get_share_list" -> {
                if (call.arguments == null || call.argument<String>(ID).isNullOrEmpty()) {
                    result.error("PARAM_ERROR", "Illegal parameter", null)
                } else {
                    val dsmId = call.argument<String>(ID)!!
                    val dsm = dsmCache[dsmId]!!

                    @SuppressLint("StaticFieldLeak")
                    val task = object : AsyncTask<Void?, Void?, Any?>() {
                        override fun doInBackground(vararg params: Void?): Any? {
                            return dsm.getShareList()
                        }

                        override fun onPostExecute(jsonList: Any?) {
                            super.onPostExecute(jsonList)
                            result.success(jsonList)
                        }

                    }
                    task.execute()
                }
            }
            "DSM_tree_connect" -> {
                if (call.arguments == null || call.argument<String>(ID).isNullOrEmpty() || call.argument<String>(NAME).isNullOrEmpty()) {
                    result.error("PARAM_ERROR", "Illegal parameter", null)
                } else {
                    val dsmId = call.argument<String>(ID)!!
                    val name = call.argument<String>(NAME)!!
                    val dsm = dsmCache[dsmId]!!

                    @SuppressLint("StaticFieldLeak")
                    val task = object : AsyncTask<Void?, Void?, Any?>() {
                        override fun doInBackground(vararg params: Void?): Any {
                            return dsm.treeConnect(name)
                        }

                        override fun onPostExecute(connectStatus: Any?) {
                            super.onPostExecute(connectStatus)
                            result.success(connectStatus)
                        }

                    }
                    task.execute()
                }
            }
            "DSM_tree_disconnect" -> {
                if (call.arguments == null || call.argument<String>(ID).isNullOrEmpty() || call.argument<Int>(TID) == null) {
                    result.error("PARAM_ERROR", "Illegal parameter", null)
                } else {
                    val dsmId = call.argument<String>(ID)!!
                    val tid = call.argument<Int>(TID)!!
                    val dsm = dsmCache[dsmId]!!

                    @SuppressLint("StaticFieldLeak")
                    val task = object : AsyncTask<Void?, Void?, Any?>() {
                        override fun doInBackground(vararg params: Void?): Any {
                            return dsm.treeDisconnect(tid)
                        }

                        override fun onPostExecute(disconnectStatus: Any?) {
                            super.onPostExecute(disconnectStatus)
                            result.success(disconnectStatus)
                        }

                    }
                    task.execute()
                }
            }
            "DSM_find" -> {
                if (call.arguments == null ||
                        call.argument<String>(ID).isNullOrEmpty() ||
                        call.argument<Int>(TID) == null ||
                        call.argument<String>(PATTERN).isNullOrEmpty()
                ) {
                    result.error("PARAM_ERROR", "Illegal parameter", null)
                } else {
                    val dsmId = call.argument<String>(ID)!!
                    val tid = call.argument<Int>(TID)!!
                    val pattern = call.argument<String>(PATTERN)!!
                    val dsm = dsmCache[dsmId]!!

                    @SuppressLint("StaticFieldLeak")
                    val task = object : AsyncTask<Void?, Void?, Any?>() {
                        override fun doInBackground(vararg params: Void?): Any? {
                            return dsm.find(tid, pattern)
                        }

                        override fun onPostExecute(findResult: Any?) {
                            super.onPostExecute(findResult)
                            result.success(findResult)
                        }

                    }
                    task.execute()
                }
            }
            "DSM_file_status" -> {
                if (call.arguments == null ||
                        call.argument<String>(ID).isNullOrEmpty() ||
                        call.argument<Int>(TID) == null ||
                        call.argument<String>(PATH).isNullOrEmpty()
                ) {
                    result.error("PARAM_ERROR", "Illegal parameter", null)
                } else {
                    val dsmId = call.argument<String>(ID)!!
                    val tid = call.argument<Int>(TID)!!
                    val path = call.argument<String>(PATH)!!
                    val dsm = dsmCache[dsmId]!!

                    @SuppressLint("StaticFieldLeak")
                    val task = object : AsyncTask<Void?, Void?, Any?>() {
                        override fun doInBackground(vararg params: Void?): Any? {
                            return dsm.fileStatus(tid, path)
                        }

                        override fun onPostExecute(fileStatus: Any?) {
                            super.onPostExecute(fileStatus)
                            result.success(fileStatus)
                        }

                    }
                    task.execute()
                }
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {}

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        Log.i(TAG, "onListen() called with: arguments = [$arguments], events = [$events]")
        if (arguments == null) {
            events?.error("PARAM_ERROR", "Illegal parameter", null)
        } else {
            val dsmId = arguments as String
            val dsm = dsmCache[dsmId]
            dsm?.discoveryListener = object : Dsm.DiscoveryListener {

                override fun onEntryAdded(json: JSONObject) {
                    val resultJson = JSONObject()
                    resultJson["type"] = Dsm.Companion.EventType.DISCOVERY_ADD.value
                    resultJson["result"] = json
                    events?.success(resultJson.toString())
                }

                override fun onEntryRemoved(json: JSONObject) {
                    val resultJson = JSONObject()
                    resultJson["type"] = Dsm.Companion.EventType.DISCOVERY_REMOVE.value
                    resultJson["result"] = json
                    events?.success(resultJson.toString())
                }
            }
        }
    }

    override fun onCancel(arguments: Any?) {
        Log.i(TAG, "onCancel() called with: arguments = [$arguments]")
        if (arguments != null) {
            val dsmId = arguments as String
            val dsm = dsmCache[dsmId]
            dsm?.discoveryListener = null
        }
    }

}
