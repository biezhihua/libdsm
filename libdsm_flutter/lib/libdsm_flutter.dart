import 'dart:async';

import 'package:flutter/services.dart';

class LibdsmFlutter {
  static const MethodChannel _channel =
      const MethodChannel('libdsm_flutter');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
