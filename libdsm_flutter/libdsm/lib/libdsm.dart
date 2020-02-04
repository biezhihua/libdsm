import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Dsm {
  static const String TAG = "[DSM][FLUTTER]";

  static const int EVENT_ENTRY_ADDED = 0;

  static const int EVENT_ENTRY_REMOVE = 1;

  String _dsmId;

  String get dsmId => _dsmId;

  MethodChannel _methodChannel;
  EventChannel _eventChannel;
  Stream<String>_discoveryListener;

  Dsm() {
    _methodChannel = const MethodChannel('open.flutter/libdsm');
    _eventChannel = const EventChannel('open.flutter/discovery_listener');
  }

  Stream<String> get onDiscoveryChanged {
    if (_discoveryListener == null) {
      _discoveryListener = _eventChannel
          .receiveBroadcastStream(_dsmId)
          .cast<String>();
    }
    return _discoveryListener;
  }

  void init() async {
    if (_dsmId != null){
      return;
    }
    _dsmId = await _methodChannel.invokeMethod<String>('DSM_init');
  }

  void release() async {
    if (_dsmId == null) {
      return;
    }
    await _methodChannel.invokeMethod('DSM_release', <String, dynamic>{
      'id': _dsmId,
    });
    _dsmId = null;
  }

  void startDiscovery({int timeout = 4}) async {
    if (_dsmId == null) {
      return;
    }
    await _methodChannel.invokeMethod('DSM_start_discovery',
        <String, dynamic>{'id': _dsmId, 'time_out': timeout});
  }

  void stopDiscovery() async {
    if (_dsmId == null) {
      return;
    }
    await _methodChannel
        .invokeMethod('DSM_stop_discovery', <String, dynamic>{'id': _dsmId});
  }

  Future<String> resolve(String name) async {
    if (_dsmId == null) {
      return "";
    }
    String address = await _methodChannel.invokeMethod(
        'DSM_resolve', <String, dynamic>{'id': _dsmId, 'name': name});
    return address;
  }

  Future<String> inverse(String address) async {
    if (_dsmId == null) {
      return "";
    }
    String name = await _methodChannel.invokeMethod(
        'DSM_inverse', <String, dynamic>{'id': _dsmId, 'address': address});
    return name;
  }

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

  Future<int> logout() async {
    if (_dsmId == null) {
      return 0;
    }
    int result = await _methodChannel
        .invokeMethod('DSM_logout', <String, dynamic>{'id': _dsmId});
    return result;
  }

  Future<String> getShareList() async {
    if (_dsmId == null) {
      return "";
    }
    String listJson = await _methodChannel
        .invokeMethod('DSM_get_share_list', <String, dynamic>{'id': _dsmId});
    return listJson;
  }

  Future<int> treeConnect(String name) async {
    if (_dsmId == null) {
      return 0;
    }
    int tid = await _methodChannel.invokeMethod(
        'DSM_tree_connect', <String, dynamic>{'id': _dsmId, 'name': name});
    return tid;
  }

  Future<int> treeDisconnect(int tid) async {
    if (_dsmId == null) {
      return 0;
    }
    int result = await _methodChannel.invokeMethod(
        'DSM_tree_disconnect', <String, dynamic>{'id': _dsmId, 'tid': tid});
    return result;
  }

  Future<String> find(int tid, String pattern) async {
    if (_dsmId == null) {
      return "";
    }
    String resultJson = await _methodChannel.invokeMethod('DSM_find',
        <String, dynamic>{'id': _dsmId, 'tid': tid, 'pattern': pattern});
    return resultJson;
  }

  Future<String> fileStatus(int tid, String path) async {
    if (_dsmId == null) {
      return "";
    }
    String resultJson = await _methodChannel.invokeMethod('DSM_file_status',
        <String, dynamic>{'id': _dsmId, 'tid': tid, 'path': path});
    return resultJson;
  }
}
