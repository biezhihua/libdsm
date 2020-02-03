import Flutter
import UIKit

public class SwiftDsmPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    
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
    
    let cacheDsm: [String: String] = [:]
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let methodChannel = FlutterMethodChannel(name: "open.flutter/libdsm", binaryMessenger: registrar.messenger())
        let eventChannel = FlutterEventChannel(name: "open.flutter/discovery_listener", binaryMessenger: registrar.messenger())
        let instance = SwiftDsmPlugin()
        registrar.addMethodCallDelegate(instance, channel: methodChannel)
        eventChannel.setStreamHandler(instance)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        NSLog("call.method = \(call.method) call.arguments = \(String(describing: call.arguments))")
        
        switch call.method {
        case "DSM_init":
            result(nil)
            break
        case "DSM_release":
            result(nil)
            break
        case "DSM_start_discovery":
            result(nil)
            break
        case "DSM_stop_discovery":
            result(nil)
            break
        case "DSM_resolve":
            result(nil)
            break
        case "DSM_inverse":
            result(nil)
            break
        case "DSM_login":
            result(nil)
            break
        case "DSM_logout":
            result(nil)
            break
        case "DSM_get_share_list":
            result(nil)
            break
        case "DSM_tree_connect":
            result(nil)
            break
        case "DSM_tree_disconnect":
            result(nil)
            break
        case "DSM_find":
            result(nil)
            break
        case "DSM_file_status":
            result(nil)
            break
        default:
            result(FlutterMethodNotImplemented)
        }
        
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        return nil
    }
}
