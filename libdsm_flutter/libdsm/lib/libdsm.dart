import 'dart:async';

import 'package:flutter/services.dart';

/// An Android wrapper for the libdsm library。
/// https://videolabs.github.io/libdsm/
class Dsm {
  static const String TAG = "[DSM][FLUTTER]";

  static const int EVENT_ENTRY_ADDED = 0;

  static const int EVENT_ENTRY_REMOVE = 1;

  String _dsmId;

  String get dsmId => _dsmId;

  MethodChannel _methodChannel;
  EventChannel _eventChannel;
  Stream<String> _discoveryListener;

  Dsm() {
    _methodChannel = const MethodChannel('open.flutter/libdsm');
    _eventChannel = const EventChannel('open.flutter/discovery_listener');
  }

  Stream<String> get onDiscoveryChanged {
    if (_discoveryListener == null) {
      _discoveryListener =
          _eventChannel.receiveBroadcastStream(_dsmId).cast<String>();
    }
    return _discoveryListener;
  }

  /// Initialize the library, set environment variables, and bind C ++ object to Java object.
  void init() async {
    if (_dsmId != null) {
      return;
    }
    _dsmId = await _methodChannel.invokeMethod<String>('DSM_init');
  }

  /// Release the library and unbind the binding relationship, otherwise it may cause a memory leak.
  void release() async {
    if (_dsmId == null) {
      return;
    }
    await _methodChannel.invokeMethod('DSM_release', <String, dynamic>{
      'id': _dsmId,
    });
    _dsmId = null;
  }

  /// Start to discover the SMB server in the local area network.
  /// When any SMB server is found or when the SMB server is disappears, a callback notification will be generated.
  void startDiscovery({int timeout = 4}) async {
    if (_dsmId == null) {
      return;
    }
    await _methodChannel.invokeMethod('DSM_start_discovery',
        <String, dynamic>{'id': _dsmId, 'time_out': timeout});
  }

  /// Stop discovering SMB servers in the LAN.
  void stopDiscovery() async {
    if (_dsmId == null) {
      return;
    }
    await _methodChannel
        .invokeMethod('DSM_stop_discovery', <String, dynamic>{'id': _dsmId});
  }

  /// Resolve a Netbios name
  ///
  /// This function tries to resolves the given NetBIOS name with the
  /// given type on the LAN, using broadcast queries. No WINS server is called.
  Future<String> resolve(String name) async {
    if (_dsmId == null) {
      return "";
    }
    String address = await _methodChannel.invokeMethod(
        'DSM_resolve', <String, dynamic>{'id': _dsmId, 'name': name});
    return address;
  }

  /// Perform an inverse netbios resolve (get name from ip)
  ///
  /// This function does a NBSTAT and stores all the returned entry in
  /// the internal list of entries. It returns one of the name found. (Normally
  /// the <20> or <0> name)
  Future<String> inverse(String address) async {
    if (_dsmId == null) {
      return "";
    }
    String name = await _methodChannel.invokeMethod(
        'DSM_inverse', <String, dynamic>{'id': _dsmId, 'address': address});
    return name;
  }

  /// Login to an SMB server, if login fails, it will try to log in again with Gust identity.
  Future<int> login(String host, String loginName, String password) async {
    if (_dsmId == null) {
      return 0;
    }
    int result =
        await _methodChannel.invokeMethod('DSM_login', <String, dynamic>{
      'id': _dsmId,
      'host': host,
      'login_name': loginName,
      'password': password,
    });
    return result;
  }

  /// Exit from an SMB server.
  ///
  /// @return 0 = SUCCESS OR ERROR
  Future<int> logout() async {
    if (_dsmId == null) {
      return 0;
    }
    int result = await _methodChannel
        .invokeMethod('DSM_logout', <String, dynamic>{'id': _dsmId});
    return result;
  }

  /// List the existing share of this sessions's machine
  ///
  /// This function makes a RPC to the machine this session is currently
  /// authenticated to and list all the existing shares of this machines. The share
  /// starting with a $ are supposed to be system/hidden share.
  ///
  /// @return An a json list.
  Future<String> getShareList() async {
    if (_dsmId == null) {
      return "";
    }
    String listJson = await _methodChannel
        .invokeMethod('DSM_get_share_list', <String, dynamic>{'id': _dsmId});
    return listJson;
  }

  /// Connects to a SMB share
  ///
  /// Before being able to list/read files on a SMB file server, you have
  /// to be connected to the share containing the files you want to read or
  /// the directories you want to list
  ///
  /// @param name The share name @see smb_share_list
  /// @return tid
  Future<int> treeConnect(String name) async {
    if (_dsmId == null) {
      return 0;
    }
    int tid = await _methodChannel.invokeMethod(
        'DSM_tree_connect', <String, dynamic>{'id': _dsmId, 'name': name});
    return tid;
  }

  /// Disconnect from a share
  ///
  /// @return 0 on success or a DSM error code in case of error
  Future<int> treeDisconnect(int tid) async {
    if (_dsmId == null) {
      return 0;
    }
    int result = await _methodChannel.invokeMethod(
        'DSM_tree_disconnect', <String, dynamic>{'id': _dsmId, 'tid': tid});
    return result;
  }

  /// Returns infos about files matching a pattern
  ///
  /// This functions uses the FIND_FIRST2 SMB operations to list files
  /// matching a certain pattern. It's basically used to list folder contents
  ///
  /// @param pattern The pattern to match files. '\\*' will list all the files at
  /// the root of the share. '\\afolder\\*' will list all the files inside of the
  /// 'afolder' directory.
  ///
  /// @return An json list of files.
  Future<String> find(int tid, String pattern) async {
    if (_dsmId == null) {
      return "";
    }
    String resultJson = await _methodChannel.invokeMethod('DSM_find',
        <String, dynamic>{'id': _dsmId, 'tid': tid, 'pattern': pattern});
    return resultJson;
  }

  /// Get the status of a file from it's path inside of a share
  ///
  /// @param path The full path of the file relative to the root of the share
  /// (e.g. '\\folder\\file.ext')
  ///
  /// @return An opaque smb_stat or NULL in case of error. You need to
  /// destory this object with smb_stat_destroy after usage.
  Future<String> fileStatus(int tid, String path) async {
    if (_dsmId == null) {
      return "";
    }
    String resultJson = await _methodChannel.invokeMethod('DSM_file_status',
        <String, dynamic>{'id': _dsmId, 'tid': tid, 'path': path});
    return resultJson;
  }
}
