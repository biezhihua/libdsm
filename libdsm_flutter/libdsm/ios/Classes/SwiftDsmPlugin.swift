import Flutter
import UIKit
import libdsm_ios

public class SwiftDsmPlugin: NSObject, FlutterPlugin, FlutterStreamHandler,DiscoveryListener{
    
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

        let args = call.arguments as? [String:Any]
        
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
            let dsmId = args![SwiftDsmPlugin.ID] as! String
            let dsm = dsmCache[dsmId]
            dsmCache.removeValue(forKey: dsmId)
            dsm?.dsmRelease()
            result(nil)
            break
        case "DSM_start_discovery":
            if (args == nil || args?[SwiftDsmPlugin.ID] == nil) {
                result(FlutterError(code: "PARAM_ERROR", message: "Illegal parameter", details: nil))
                break
            } else {
                let dsmId = args![SwiftDsmPlugin.ID] as! String
                let timeOut = args![SwiftDsmPlugin.TIME_OUT] as? Int32
                let dsm = dsmCache[dsmId]
                dsm?.startDiscovery(timeOut == nil ? 4 : timeOut!)
                result(nil)
            }
            break
        case "DSM_stop_discovery":
            if (args == nil || args?[SwiftDsmPlugin.ID] == nil) {
                result(FlutterError(code: "PARAM_ERROR", message: "Illegal parameter", details: nil))
                break
            } else {
                let dsmId = args![SwiftDsmPlugin.ID] as! String
                let dsm = dsmCache[dsmId]
                dsm?.stopDiscovery()
                result(nil)
            }
            break
        case "DSM_resolve":
            if (args == nil || args?[SwiftDsmPlugin.ID] == nil || args?[SwiftDsmPlugin.NAME] == nil) {
                result(FlutterError(code: "PARAM_ERROR", message: "Illegal parameter", details: nil))
                break
            } else {
                let dsmId = args![SwiftDsmPlugin.ID] as! String
                let name = args![SwiftDsmPlugin.NAME] as! String
                let dsm = dsmCache[dsmId]
                
                DispatchQueue.global().async(){
                    let address = dsm?.resolve(name)
                    DispatchQueue.main.async {
                        result(address)
                    }
                }
            }
            break
        case "DSM_inverse":
            if (args == nil || args?[SwiftDsmPlugin.ID] == nil || args?[SwiftDsmPlugin.ADDRESS] == nil) {
                result(FlutterError(code: "PARAM_ERROR", message: "Illegal parameter", details: nil))
                break
            } else {
                let dsmId = args![SwiftDsmPlugin.ID] as! String
                let address = args![SwiftDsmPlugin.ADDRESS] as! String
                let dsm = dsmCache[dsmId]
                
                DispatchQueue.global().async(){
                    let name = dsm?.inverse(address)
                    DispatchQueue.main.async {
                        result(name)
                    }
                }
            }
            break
        case "DSM_login":
            if (args == nil ||
                args?[SwiftDsmPlugin.ID] == nil ||
                args?[SwiftDsmPlugin.HOST] == nil ||
                args?[SwiftDsmPlugin.LOGIN_NAME] == nil ||
                args?[SwiftDsmPlugin.PASSWORD] == nil
                ) {
                result(FlutterError(code: "PARAM_ERROR", message: "Illegal parameter", details: nil))
                break
            } else {
                let dsmId = args![SwiftDsmPlugin.ID] as! String
                let host = args![SwiftDsmPlugin.HOST] as! String
                let loginName = args![SwiftDsmPlugin.LOGIN_NAME] as! String
                let password = args![SwiftDsmPlugin.PASSWORD] as! String
                let dsm = dsmCache[dsmId]
                
                DispatchQueue.global().async(){
                    let loginResult = dsm?.login(host, loginName, password)
                    DispatchQueue.main.async {
                        result(loginResult)
                    }
                }
            }
            break
        case "DSM_logout":
            if (args == nil ||
                args?[SwiftDsmPlugin.ID] == nil
                ) {
                result(FlutterError(code: "PARAM_ERROR", message: "Illegal parameter", details: nil))
                break
            } else {
                let dsmId = args![SwiftDsmPlugin.ID] as! String
                let dsm = dsmCache[dsmId]
                result(dsm?.logout())
                
                DispatchQueue.global().async(){
                    let logoutResult = dsm?.logout()
                    DispatchQueue.main.async {
                        result(logoutResult)
                    }
                }
            }
            break
        case "DSM_get_share_list":
            if (args == nil ||
                args?[SwiftDsmPlugin.ID] == nil
                ) {
                result(FlutterError(code: "PARAM_ERROR", message: "Illegal parameter", details: nil))
                break
            } else {
                let dsmId = args![SwiftDsmPlugin.ID] as! String
                let dsm = dsmCache[dsmId]
                
                DispatchQueue.global().async(){
                    let shareListResult = dsm?.getShareList()
                    DispatchQueue.main.async {
                        result(shareListResult)
                    }
                }
            }
            break
        case "DSM_tree_connect":
            if (args == nil ||
                args?[SwiftDsmPlugin.ID] == nil ||
                args?[SwiftDsmPlugin.NAME] == nil
                ) {
                result(FlutterError(code: "PARAM_ERROR", message: "Illegal parameter", details: nil))
                break
            } else {
                let dsmId = args![SwiftDsmPlugin.ID] as! String
                let name = args![SwiftDsmPlugin.NAME] as! String
                let dsm = dsmCache[dsmId]
                
                DispatchQueue.global().async(){
                    let executeResult = dsm?.treeConnect(name)
                    DispatchQueue.main.async {
                        result(executeResult)
                    }
                }
            }
            break
        case "DSM_tree_disconnect":
            if (args == nil ||
                args?[SwiftDsmPlugin.ID] == nil ||
                args?[SwiftDsmPlugin.TID] == nil
                ) {
                result(FlutterError(code: "PARAM_ERROR", message: "Illegal parameter", details: nil))
                break
            } else {
                let dsmId = args![SwiftDsmPlugin.ID] as! String
                let tid = args![SwiftDsmPlugin.TID] as! Int32
                let dsm = dsmCache[dsmId]
                
                DispatchQueue.global().async(){
                    let executeResult = dsm?.treeDisconnect(tid)
                    DispatchQueue.main.async {
                        result(executeResult)
                    }
                }
            }
            break
        case "DSM_find":
            if (args == nil ||
                args?[SwiftDsmPlugin.ID] == nil ||
                args?[SwiftDsmPlugin.TID] == nil ||
                args?[SwiftDsmPlugin.PATTERN] == nil
                ) {
                result(FlutterError(code: "PARAM_ERROR", message: "Illegal parameter", details: nil))
                break
            } else {
                let dsmId = args![SwiftDsmPlugin.ID] as! String
                let tid = args![SwiftDsmPlugin.TID] as! Int32
                let pattern = args![SwiftDsmPlugin.PATTERN] as! String
                let dsm = dsmCache[dsmId]
                
                DispatchQueue.global().async(){
                    let executeResult = dsm?.find(tid, pattern)
                    DispatchQueue.main.async {
                        result(executeResult)
                    }
                }
            }
            break
        case "DSM_file_status":
            if (args == nil ||
                args?[SwiftDsmPlugin.ID] == nil ||
                args?[SwiftDsmPlugin.TID] == nil ||
                args?[SwiftDsmPlugin.PATH] == nil
                ) {
                result(FlutterError(code: "PARAM_ERROR", message: "Illegal parameter", details: nil))
                break
            } else {
                let dsmId = args![SwiftDsmPlugin.ID] as! String
                let tid = args![SwiftDsmPlugin.TID] as! Int32
                let path = args![SwiftDsmPlugin.PATH] as! String
                let dsm = dsmCache[dsmId]
                
                DispatchQueue.global().async(){
                    let executeResult = dsm?.fileStatus(tid, path)
                    DispatchQueue.main.async {
                        result(executeResult)
                    }
                }
            }
            break
        default:
            result(FlutterMethodNotImplemented)
        }
        
    }
    
    var _eventSink : FlutterEventSink? = nil
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        
        NSLog("events = \(String(describing: events)) arguments = \(String(describing: arguments))")
        
        if (arguments == nil) {
            events(FlutterError.init(code: "PARAM_ERROR", message: "Illegal parameter", details: nil))
        } else {
            let dsmId = arguments as! String
            let dsm = dsmCache[dsmId]
            dsm?.discoveryListener = self
            _eventSink = events
        }
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        if (arguments != nil) {
            let dsmId = arguments as! String
            let dsm = dsmCache[dsmId]
            dsm?.discoveryListener = nil
            _eventSink = nil
        }
        return nil
    }
    
    public func onEntryAdded(json: String) {
        let result = convertToDictionary(text: json) ?? [:]
        let dic = ["type":"0", "result": result] as [String : Any]
        let jsonData = try! JSONSerialization.data(withJSONObject: dic)
        _eventSink?(String(data: jsonData, encoding: .utf8))
    }
    
    public func onEntryRemoved(json: String) {
        let result = convertToDictionary(text: json) ?? [:]
        let dic = ["type":"1", "result":result ] as [String : Any]
        let jsonData = try! JSONSerialization.data(withJSONObject: dic)
        _eventSink?(String(data: jsonData, encoding: .utf8))
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                
            }
        }
        return nil
    }
    
}
