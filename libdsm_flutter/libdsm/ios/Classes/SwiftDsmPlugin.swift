import Flutter
import UIKit
import libdsm_ios

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
    
    var dsmCache: [String: Dsm] = [:]
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let methodChannel = FlutterMethodChannel(name: "open.flutter/libdsm", binaryMessenger: registrar.messenger())
        let eventChannel = FlutterEventChannel(name: "open.flutter/discovery_listener", binaryMessenger: registrar.messenger())
        let instance = SwiftDsmPlugin()
        registrar.addMethodCallDelegate(instance, channel: methodChannel)
        eventChannel.setStreamHandler(instance)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        //        call.method = DSM_release call.arguments = Optional({
        //            id = "51CDB8F3-5DA0-466A-A6E2-22198AE4D4D1";
        //        })
        
        let args = call.arguments as? [String:String]
        
        NSLog("call.method = \(call.method) call.arguments = \(String(describing: args))")
        
        switch call.method {
        case "DSM_init":
            let dsm = Dsm()
            let dsmId = UUID.init().uuidString
            dsmCache[dsmId] = dsm
            result(dsmId)
            break
        case "DSM_release":
            if (args == nil || args?[SwiftDsmPlugin.ID] == nil) {
                result(FlutterError(code: "PARAM_ERROR", message: "Illegal parameter", details: nil))
                 break
            }
            let dsmId = args![SwiftDsmPlugin.ID]!
            let dsm = dsmCache[dsmId]
            dsmCache.removeValue(forKey: dsmId)
            dsm?.dsmRelease()
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
