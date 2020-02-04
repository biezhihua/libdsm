# Introduction

An Flutter (Android & iOS) wrapper for the libdsm library


# Dependence Library

* C++ Json Library : https://github.com/nlohmann/json
* Plain'OI C Defective SMB Library  : https://videolabs.github.io/libdsm/

# Example the function

```
  Dsm dsm = Dsm();

  void _create() async {
    await dsm.init();
  }

  void _release() async {
    await dsm.release();
  }

  void _startDiscovery() async {
    dsm.onDiscoveryChanged.listen(_discoveryListener);
    await dsm.startDiscovery();
  }

  void _discoveryListener(String json) async {
    debugPrint('Discovery : $json');
  }

  void _stopDiscovery() async {
    dsm.onDiscoveryChanged.listen(null);
    await dsm.stopDiscovery();
  }

  void _resolve() async {
    String name = 'biezhihua';
    await dsm.resolve(name);
  }

  void _inverse() async {
    String address = '192.168.1.1';
    await dsm.inverse(address);
  }

  void _login() async {
    await dsm.login("BIEZHIHUA-PC", "test", "test");
  }

  void _logout() async {
    await dsm.logout();
  }

  void _getShareList() async {
    await dsm.getShareList();
  }

  int tid = 0;

  void _treeConnect() async {
    tid = await dsm.treeConnect("F");
  }

  void _treeDisconnect() async {
    int result = await dsm.treeDisconnect(tid);
    tid = 0;
  }

  void _find() async {
    String result = await dsm.find(tid, "\\*");

    result = await dsm.find(tid, "\\splayer\\splayer_soundtouch\\*");
  }

  void _fileStatus() async {
    String result =
        await dsm.fileStatus(tid, "\\splayer\\splayer_soundtouch\\Test.cpp");
  }
```