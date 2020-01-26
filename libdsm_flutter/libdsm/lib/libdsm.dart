import 'dart:async';

import 'package:flutter/services.dart';

class Dsm {
  static const String TAG = "[DSM][FLUTTER]";

  final MethodChannel _channel = const MethodChannel('libdsm');

   Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  Dsm() {

  }

  void init() {}

  void release() {}

  void startDiscovery(int timeout) {}

  void stopDiscovery() {}

  String resolve(String name) {
    return "";
  }

  String inverse(String address) {
    return "";
  }

  int login(String host, String loginName, String password) {
    return 0;
  }

  int logout() {
    return 0;
  }

  String getShareList() {
    return "";
  }

  int treeConnect(String name) {
    return 0;
  }

  String treeDisconnect(int tid) {
    return "";
  }

  String find(int tid, String pattern) {
    return "";
  }

  String fileStatus(int tid, String path) {
    return "";
  }
}
