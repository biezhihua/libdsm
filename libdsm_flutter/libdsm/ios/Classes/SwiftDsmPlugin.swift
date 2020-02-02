import Flutter
import UIKit

public class SwiftDsmPlugin: NSObject, FlutterPlugin {
    
    static  let ID = "id"
    static  let TIME_OUT = "time_out"
    static  let NAME = "name"
    static  let ADDRESS = "address"
    static  let HOST = "host"
    static  let LOGIN_NAME = "login_name"
    static  let PASSWORD = "password"
    static  let TID = "tid"
    static  let PATTERN = "pattern"
    static  let PATH = "path"
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "open.flutter/libdsm", binaryMessenger: registrar.messenger())
        let instance = SwiftDsmPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        NSLog("call.method = \(call.method) call.arguments = \(call.arguments) biezhihua")
        
        switch call.method {
        case "DSM_init":
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }

    }
}
