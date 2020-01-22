using UnityEngine;

public class Dsm {

    private const string TAG = "[DSM][UNITY]";

    private const int DSM_SUCCESS = 0;

    private const int DSM_ERROR = -100;

    public static void Log(string message) {
        Debug.Log($"{TAG} {message}");
    }

    public static void Log(string tag, string message) {
        Debug.Log($"{tag} {message}");
    }

    public interface DiscoveryListener {

        void onEntryAdded(string json);

        void onEntryRemoved(string json);

    }

    private class JavaImplDiscoveryListener : AndroidJavaProxy {

        private readonly DiscoveryListener listener;

        public JavaImplDiscoveryListener(DiscoveryListener listener) : base(
            "open.android.lib.dsm.Dsm$DiscoveryListener") {
            this.listener = listener;
        }

        public void onEntryAdded(string json) {
            listener?.onEntryAdded(json);
        }

        public void onEntryRemoved(string json) {
            listener?.onEntryRemoved(json);
        }

    }

    private readonly AndroidJavaObject javaDsm;

    private JavaImplDiscoveryListener javaListener;

    public void setDiscoveryListener(DiscoveryListener listener) {
        javaListener = new JavaImplDiscoveryListener(listener);
        javaDsm?.Call("setDiscoveryListener", javaListener);
    }

    public Dsm() {
        javaDsm = new AndroidJavaObject("open.android.lib.dsm.Dsm");
    }

    public void init() {
        javaDsm?.Call("init");
    }

    public void release() {
        javaDsm?.Call("release");
    }

    public void startDiscovery(int timeout = 4) {
        javaDsm?.Call("startDiscovery", timeout);
    }

    public void stopDiscovery() {
        javaDsm?.Call("startDiscovery");
    }

    public string resolve(string name) {
        return javaDsm?.Call<string>("resolve", name);
    }

    public string inverse(string address) {
        return javaDsm?.Call<string>("inverse", address);
    }

    public int login(string host, string loginName, string password) {
        return javaDsm?.Call<int>("login", host, loginName, password) ?? DSM_ERROR;
    }

    public int logout() {
        return javaDsm?.Call<int>("logout") ?? DSM_ERROR;
    }

    public string getShareList() {
        return javaDsm.Call<string>("getShareList");
    }

    public int treeConnect(string name) {
        return javaDsm.Call<int>("treeConnect", name);
    }

    public string treeDisconnect(int tid) {
        return javaDsm.Call<string>("treeDisconnect", tid);
    }

    public string find(int tid, string pattern) {
        return javaDsm.Call<string>("find", tid, pattern);
    }

    public string fileStatus(int tid, string path) {
        return javaDsm.Call<string>("fileStatus", tid, path);
    }

}