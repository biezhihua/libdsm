import dsm_birdge

/*
 * An iOS wrapper for the libdsm library。
 * https://videolabs.github.io/libdsm/
 */
public class Dsm {
    private class DsmHolder {
        //
        fileprivate var dsm: Dsm?
    }

    private static let TAG = "[DSM][SWIFT]"

    // Called when an SMB device is found
    public static let EVENT_TYPE_ON_DISCOVERY_ADD: Int32 = 0

    // Called when an SMB device is removed
    public static let EVENT_TYPE_ON_DISCOVERY_REMOVE: Int32 = 1

    // Dsm object holder
    private var dsmHolder = DsmHolder()

    // Native pointer to DSM object
    private var dsmNativePointer: Int64 = 0

    // 
    public var discoveryListener: DiscoveryListener?

    public init() {
        // Register a callback method for static communication
        // Converts static communication to object communication
        DSM_onEventFromNative = { (dsmSelf: UnsafeMutableRawPointer, what: Int32, json: UnsafePointer<Int8>?) -> Void in
            if json != nil {
                let jsonData = String(cString: json!).data(using: .utf8)
                if jsonData != nil {
                    let rawJson = try? JSONSerialization.jsonObject(with: jsonData!, options: .mutableContainers) as AnyObject
                    if rawJson != nil {
                        var resultJson: Data?
                        if #available(iOS 13.0, *) {
                            resultJson = try? JSONSerialization.data(withJSONObject: rawJson as Any, options: JSONSerialization.WritingOptions.withoutEscapingSlashes)
                        } else {
                            resultJson = try? JSONSerialization.data(withJSONObject: rawJson as Any, options: JSONSerialization.WritingOptions.prettyPrinted)
                        }
                        if resultJson != nil {
                            let dsmRawSelf = dsmSelf.load(as: DsmHolder.self)
                            dsmRawSelf.dsm?.onEventFromNative(what, String(data: resultJson!, encoding: String.Encoding.utf8) ?? "")
                        }
                    }
                }
            }
        }

        // Save dsm reference
        dsmHolder.dsm = self

        dsmInit()
    }

    public func onEventFromNative(_ what: Int32, _ json: String) {
        DispatchQueue.main.async {
            switch what {
            case Dsm.EVENT_TYPE_ON_DISCOVERY_ADD:
                self.discoveryListener?.onEntryAdded(json: json)
            case Dsm.EVENT_TYPE_ON_DISCOVERY_REMOVE:
                self.discoveryListener?.onEntryRemoved(json: json)
            default:
                break
            }
        }
    }

    /*
     * Initialize the library, set environment variables, and bind C ++ object to Swift object.
     */
    public func dsmInit() {
        DSM_init(UnsafeMutableRawPointer(&dsmHolder), &dsmNativePointer)
    }

    /*
     * Release the library and unbind the binding relationship, otherwise it may cause a memory leak.
     */
    public func dsmRelease() {
        DSM_release(UnsafeMutableRawPointer(&dsmHolder), &dsmNativePointer)
    }

    deinit {
        // Release dsm holder reference
        dsmHolder.dsm = nil
        dsmRelease()
    }

    /*
     * Start to discover the SMB server in the local area network.
     * When any SMB server is found or when the SMB server is disappears, a callback notification will be generated.
     */
    public func startDiscovery(_ timeOut: Int32 = 4) {
        DSM_startDiscovery(UnsafeMutableRawPointer(&dsmHolder), &dsmNativePointer, timeOut)
    }

    /*
     * Stop discovering SMB servers in the LAN.
     */
    public func stopDiscovery() {
        DSM_stopDiscovery(UnsafeMutableRawPointer(&dsmHolder), &dsmNativePointer)
    }

    /*
     * Resolve a Netbios name
     *
     * This function tries to resolves the given NetBIOS name with the
     * given type on the LAN, using broadcast queries. No WINS server is called.
     */
    public func resolve(_ name: String) -> String {
        let result: UnsafePointer<Int8>? = DSM_resolve(UnsafeMutableRawPointer(&dsmHolder), &dsmNativePointer, name)
        if result != nil {
            let address = String(cString: result!)
            return address
        }
        return ""
    }

    /*
     * Perform an inverse netbios resolve (get name from ip)
     *
     * This function does a NBSTAT and stores all the returned entry in
     * the internal list of entries. It returns one of the name found. (Normally
     * the <20> or <0> name)
     */
    public func inverse(_ address: String) -> String {
        let result: UnsafePointer<Int8>? = DSM_inverse(UnsafeMutableRawPointer(&dsmHolder), &dsmNativePointer, address)
        if result != nil {
            let name = String(cString: result!)
            return name
        }
        return ""
    }

    /*
     * Login to an SMB server, if login fails, it will try to log in again with Gust identity.
     */
    public func login(_ host: String, _ loginName: String, _ password: String) -> Int32 {
        return DSM_login(UnsafeMutableRawPointer(&dsmHolder), &dsmNativePointer, host, loginName, password)
    }

    /*
     * Exit from an SMB server.
     *
     * @return 0 = SUCCESS OR ERROR
     */
    public func logout() -> Int32 {
        return DSM_logout(UnsafeMutableRawPointer(&dsmHolder), &dsmNativePointer)
    }

    /*
     * List the existing share of this sessions's machine
     *
     * This function makes a RPC to the machine this session is currently
     * authenticated to and list all the existing shares of this machines. The share
     * starting with a $ are supposed to be system/hidden share.
     *
     * @return An a json list.
     */
    public func getShareList() -> String {
        let result: UnsafePointer<Int8>? = DSM_shareGetListJson(UnsafeMutableRawPointer(&dsmHolder), &dsmNativePointer)
        if result != nil {
            let shareList = String(cString: result!)
            return shareList
        }
        return ""
    }

    /*
     * Connects to a SMB share
     *
     * Before being able to list/read files on a SMB file server, you have
     * to be connected to the share containing the files you want to read or
     * the directories you want to list
     *
     * @param name The share name @see smb_share_list
     * @return tid
     */
    public func treeConnect(_ name: String) -> Int32 {
        return DSM_treeConnect(UnsafeMutableRawPointer(&dsmHolder), &dsmNativePointer, name)
    }

    /*
     * Disconnect from a share
     *
     * @return 0 on success or a DSM error code in case of error
     */
    public func treeDisconnect(_ tid: Int32) -> Int32 {
        return DSM_treeDisconnect(UnsafeMutableRawPointer(&dsmHolder), &dsmNativePointer, tid)
    }

    /*
     * Returns infos about files matching a pattern
     *
     * This functions uses the FIND_FIRST2 SMB operations to list files
     * matching a certain pattern. It's basically used to list folder contents
     *
     * @param pattern The pattern to match files. '\\*' will list all the files at
     * the root of the share. '\\afolder\\*' will list all the files inside of the
     * 'afolder' directory.
     *
     * @return An json list of files.
     */
    public func find(_ tid: Int32, _ pattern: String) -> String {
        let result: UnsafePointer<Int8>? = DSM_find(UnsafeMutableRawPointer(&dsmHolder), &dsmNativePointer, tid, pattern)
        if result != nil {
            let files = String(cString: result!)
            return files
        }
        return ""
    }

    /*
     * Get the status of a file from it's path inside of a share
     *
     * @param path The full path of the file relative to the root of the share
     * (e.g. '\\folder\\file.ext')
     *
     * @return An opaque smb_stat or NULL in case of error. You need to
     * destory this object with smb_stat_destroy after usage.
     */
    public func fileStatus(_ tid: Int32, _ path: String) -> String {
        let result: UnsafePointer<Int8>? = DSM_fileStatus(UnsafeMutableRawPointer(&dsmHolder), &dsmNativePointer, tid, path)
        if result != nil {
            let fileStatus = String(cString: result!)
            return fileStatus
        }
        return ""
    }
}

/*
 * Discovery Listener
 */
public protocol DiscoveryListener {
    func onEntryAdded(json: String)
    func onEntryRemoved(json: String)
}

public enum Log {
    public static func d(_ tag: String, _ message: String) {
        NSLog("%@ %@", tag, message)
    }
}
