import Flutter
import UIKit

public class SwiftDsmPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "open.flutter/libdsm", binaryMessenger: registrar.messenger())
    let instance = SwiftDsmPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      if (call.method == "DSM_create"){
        result("iOS biezhihua")
      }else {
        result("iOS " + UIDevice.current.systemVersion)
      }
    
  }
}
