using UnityEngine;

public class DsmDemo : MonoBehaviour, Dsm.DiscoveryListener {

    private const string TAG = "[DSM][DEMO]";

    private Dsm dsm;

    private void OnEnable() {
        dsm = new Dsm();
        dsm.setDiscoveryListener(this);
    }

    private int tid;

    void OnGUI() {
        int y = 0;
        int height = Screen.height / 30;

        int space = Screen.height / 60;

        int width = Screen.width / 3;

        if (GUI.Button(new Rect(0, (y = y + height + space), width, height), "Init")) {
            dsm.init();
        }
        if (GUI.Button(new Rect(0, (y = y + height + space), width, height), "Release")) {
            dsm.release();
        }
        if (GUI.Button(new Rect(0, (y = y + height + space), width, height), "StartDiscovery")) {
            dsm.startDiscovery();
        }
        if (GUI.Button(new Rect(0, (y = y + height + space), width, height), "StopDiscovery")) {
            dsm.stopDiscovery();
        }
        if (GUI.Button(new Rect(0, (y = y + height + space), width, height), "resolve")) {
            dsm.resolve("biezhihua-pc");
        }
        if (GUI.Button(new Rect(0, (y = y + height + space), width, height), "inverse")) {
            dsm.inverse("192.168.1.1");
        }
        if (GUI.Button(new Rect(0, (y = y + height + space), width, height), "login")) {
            dsm.login("biezhihua-pc", "test", "test");
        }
        if (GUI.Button(new Rect(0, (y = y + height + space), width, height), "logout")) {
            dsm.logout();
        }
        if (GUI.Button(new Rect(0, (y = y + height + space), width, height), "getShareList")) {
            Dsm.Log(dsm.getShareList());
        }
        if (GUI.Button(new Rect(0, (y = y + height + space), width, height), "treeConnect")) {
            tid = dsm.treeConnect("F");
            Dsm.Log(tid + "");
        }
        if (GUI.Button(new Rect(0, (y = y + height + space), width, height), "logout")) {
            dsm.treeDisconnect(tid);
        }
        if (GUI.Button(new Rect(0, (y = y + height + space), width, height), "find")) {
            dsm.find(tid, "\\*");
        }
        if (GUI.Button(new Rect(0, (y = y + height + space), width, height), "fileStatus")) {
            dsm.fileStatus(tid, "\\*");
        }
    }

    public void onEntryAdded(string json) {
        Dsm.Log(TAG, $"onEntryAdded json={json}");
    }

    public void onEntryRemoved(string json) {
        Dsm.Log(TAG, $"onEntryRemoved json={json}");
    }

}