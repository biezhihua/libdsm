package open.android.lib.dsm.demo

import android.annotation.SuppressLint
import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.EditText
import android.widget.LinearLayout
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.alibaba.fastjson.JSONArray
import com.alibaba.fastjson.JSONObject
import com.google.android.material.snackbar.Snackbar
import open.android.lib.dsm.Dsm

@SuppressLint("SetTextI18n")
class MainActivity : AppCompatActivity() {

    companion object {
        private val TAG = "[DSM][MAIN]"
    }

    private var dsm: Dsm? = null
    private lateinit var root: LinearLayout
    private lateinit var server_container: RecyclerView
    private lateinit var files_container: RecyclerView
    private lateinit var tip: Snackbar
    private var discoveryProgress = 1
    private val tipUpdateTask: Runnable = object : Runnable {
        override fun run() {
            if (discoveryProgress >= 5) {
                discoveryProgress = 1
            }
            var tipProgress = ""
            for (index in 0..discoveryProgress) {
                tipProgress += "."
            }
            discoveryProgress++
            tip.setText("发现SMB服务中${tipProgress}")
            root.postDelayed(this, 300)
        }
    }
    val dsmSourceAdapter = DsmConnectAdapter(this)
    var fileSourceAdapter: DsmShareAdapter? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        root = findViewById(R.id.root)
        initDSM()
        initDiscoveryTip()
        initView()
        discoverySMB()
    }

    private fun initView() {
        server_container = findViewById(R.id.server_container)
        server_container.layoutManager = LinearLayoutManager(this)
        server_container.adapter = dsmSourceAdapter

        files_container = findViewById(R.id.files_container)
        files_container.layoutManager = LinearLayoutManager(this)
        fileSourceAdapter = DsmShareAdapter(this, dsm)
        files_container.adapter = fileSourceAdapter
    }

    private fun discoverySMB() {
        root.postDelayed({
            // 开始发现SMB服务器
            dsm?.startDiscovery()
        }, 1000)
    }

    private fun initDiscoveryTip() {
        tip = Snackbar.make(root, "发现SMB服务中", Snackbar.LENGTH_INDEFINITE)
        tip.show()
        root.postDelayed(tipUpdateTask, 300)
    }


    private fun initDSM() {
        // 初始化DSM实例
        dsm = Dsm()
        // 初始化DSM监听器
        dsm?.discoveryListener = object : Dsm.DiscoveryListener {

            override fun onEntryAdded(json: JSONObject) {
                Log.d(TAG, "onEntryAdded() called with: json = [$json]")
                tryDismissTip()

                if (json.isNotEmpty()) {
                    dsmSourceAdapter.addData(json)
                }

            }

            override fun onEntryRemoved(json: JSONObject) {
                Log.d(TAG, "onEntryRemoved() called with: json = [$json]")
            }

        }
        dsm?.init()
    }

    private fun tryDismissTip() {
        if (tip.isShown) {
            root.removeCallbacks(tipUpdateTask)
            tip.setText("已发现SMB服务器")
            root.postDelayed({
                tip.dismiss()
            }, 1000)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        dsm?.logout()
        dsm?.stopDiscovery()
        dsm?.discoveryListener = null
        dsm?.release()
        dsm = null
    }


    private fun loginDsm(
        address: String,
        name: String,
        group: String,
        username: String,
        password: String
    ) {
        val loginResult = dsm?.login(dsm?.inverse(address)!!, username, password)
        Log.d(
            TAG, "loginDsm() called with: address = [$address]," +
                    " name = [$name], group = [$group], username = [$username]," +
                    " password = [$password], loginResult = [$loginResult]"
        )
        if (loginResult == -3) {
            tip.duration = Snackbar.LENGTH_LONG
            tip.setText("错误码 $loginResult")
            tip.show()
        } else {
            dsm?.getShareList()?.let { list ->
                val shareListRawJson = list.getJSONArray("data")
                fileSourceAdapter?.addDatas(shareListRawJson)
            }
        }
    }


//    var tid: Int = 0
//
//    fun connect(view: View) {
//        tid = dsm.treeConnect("F")
//        Log.d(TAG, "connect() called with: result = [$tid]")
//    }
//
//    fun disconnect(view: View) {
//        val result = dsm.treeDisconnect(tid)
//        tid = 0
//        Log.d(TAG, "disconnect() called with: result = [$result]")
//    }
//
//    fun find(view: View) {
//        Log.d(TAG, "find() called with: result = [${dsm.find(tid, "\\*")}]")
//    }
//
//    fun openDir(view: View) {
//        Log.d(TAG, "openDir() called with: result = [${dsm.find(tid, "\\splayer\\*")}]")
//
//        Log.d(
//            TAG,
//            "openDir() called with: result = [${dsm.find(tid, "\\splayer\\splayer_soundtouch\\*")}]"
//        )
//    }
//
//    fun fileStatus(view: View) {
//        Log.d(
//            TAG,
//            "fileStatus() called with: result = [${
//                dsm.fileStatus(
//                    tid,
//                    "\\splayer\\splayer_soundtouch\\Test.cpp"
//                )
//            }]"
//        )
//    }

    class DsmConnectAdapter(val mainActivity: MainActivity) :
        RecyclerView.Adapter<DsmConnectAdapter.ViewHolder>() {

        private val dataset = JSONArray()

        class ViewHolder(view: View) : RecyclerView.ViewHolder(view) {
            val address: TextView = view.findViewById(R.id.address)
            val name: TextView = view.findViewById(R.id.name)
            val group: TextView = view.findViewById(R.id.group)
            val login: Button = view.findViewById(R.id.login)
            val username: EditText = view.findViewById(R.id.username)
            val password: EditText = view.findViewById(R.id.password)
        }

        override fun onCreateViewHolder(viewGroup: ViewGroup, viewType: Int): ViewHolder {
            val view = LayoutInflater.from(viewGroup.context)
                .inflate(R.layout.item_dsm_source, viewGroup, false)
            return ViewHolder(view)
        }

        override fun onBindViewHolder(viewHolder: ViewHolder, position: Int) {
            val itemData = dataset[position] as? JSONObject
            itemData?.let {
                val address = it.getString("address")
                val name = it.getString("name")
                val group = it.getString("group")

                viewHolder.address.text = address
                viewHolder.name.text = name
                viewHolder.group.text = group
                viewHolder.login.setOnClickListener {
                    var username = viewHolder.username.text.toString()
                    var password = viewHolder.password.text.toString()
                    mainActivity.loginDsm(address, name, group, username, password)
                }
            }
        }

        override fun getItemCount() = dataset.size

        fun addData(data: JSONObject) {
            dataset.add(data)
            notifyItemChanged(0, dataset.size)
        }

    }

    class DsmShareAdapter(val mainActivity: MainActivity, val dsm: Dsm?) :
        RecyclerView.Adapter<DsmShareAdapter.ViewHolder>() {

        private val dataset = JSONArray()

        class ViewHolder(view: View) : RecyclerView.ViewHolder(view) {
            val file_name: TextView = view.findViewById(R.id.file_name)
        }

        override fun onCreateViewHolder(viewGroup: ViewGroup, viewType: Int): ViewHolder {
            val view = LayoutInflater.from(viewGroup.context)
                .inflate(R.layout.item_dsm_file, viewGroup, false)
            return ViewHolder(view)
        }

        var path = ""
        override fun onBindViewHolder(viewHolder: ViewHolder, position: Int) {
            val itemData = dataset[position]
            if (itemData is String) {
                processShare(itemData, viewHolder)
            } else if (itemData is JSONObject) {
                val fileName = itemData.getString("name")
                viewHolder.file_name.text = fileName
                viewHolder.itemView.setOnClickListener {
                    if (tid != null) {
                        val fileStatus = dsm?.fileStatus(tid!!, path + "\\" + fileName)
                        val data = fileStatus?.getJSONObject("data")
                        val isDir = data?.getIntValue("is_dir")
                        if (isDir == 1) {
                            val dirName = data.getString("name")
                            val findNext = "$dirName\\*"
                            dsm?.find(tid!!, findNext)?.getJSONArray("data")?.let {
                                path += dirName
                                Log.d(TAG, "onBindViewHolder() called : $it")
                                setDatas(it)
                            }
                        }
                        Log.d(TAG, "onBindViewHolder() called:  status = ${fileStatus}")
                    }
                }
            }
        }

        private var tid: Int? = null

        private fun processShare(
            shareName: String,
            viewHolder: ViewHolder
        ) {
            viewHolder.file_name.text = shareName
            viewHolder.itemView.setOnClickListener {
                tid = dsm?.treeConnect(shareName)
                if (tid != null && tid!! > 0) {
                    dsm?.find(tid!!, "\\*")?.getJSONArray("data")?.let {
                        Log.d(TAG, "processShare() called : $it")
                        setDatas(it)
                    }
                } else {
                    mainActivity.tip.duration = Snackbar.LENGTH_LONG
                    mainActivity.tip.setText("错误码 $tid")
                    mainActivity.tip.show()
                }
            }
        }

        override fun getItemCount() = dataset.size

        fun addData(data: JSONObject) {
            dataset.add(data)
            notifyDataSetChanged()
        }

        fun addDatas(datas: JSONArray) {
            dataset.addAll(datas)
            notifyDataSetChanged()
        }

        fun setDatas(datas: JSONArray) {
            dataset.clear()
            dataset.addAll(datas)
            notifyDataSetChanged()
        }
    }
}
