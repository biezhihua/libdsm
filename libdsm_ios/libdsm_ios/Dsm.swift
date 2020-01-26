import dsm_birdge;

/*
 * An Android wrapper for the libdsm library。
 * https://videolabs.github.io/libdsm/
 */
public class Dsm {

    private static let TAG = "[DSM][SWIFT]"

    public static let EVENT_TYPE_ON_DISCOVERY_ADD: Int32 = 0;
    public static let EVENT_TYPE_ON_DISCOVERY_REMOVE: Int32 = 1;

    public class DsmSelf {
        var dsm: Dsm? = nil
    }

    private var dsmSelf: DsmSelf = DsmSelf()

    var dsmNative: Int64 = 0

    public var discoveryListener: DiscoveryListener? = nil

    public init() {

        // static method from native
        DSM_onEventFromNative = { (dsmSelf: UnsafeMutableRawPointer, what: Int32, json: UnsafePointer<Int8>?) -> Void in
            let dsmRawSelf = dsmSelf.load(as: DsmSelf.self)
            dsmRawSelf.dsm?.onEventFromNative(what, json != nil ? String(cString: json!) : "")
        }

        dsmSelf.dsm = self
        dsmInit()
    }

    public func onEventFromNative(_ what: Int32, _ json: String) {
        DispatchQueue.main.async() {

            switch what {
            case Dsm.EVENT_TYPE_ON_DISCOVERY_ADD:
                self.discoveryListener?.onEntryAdded(json: json)
                break;
            case Dsm.EVENT_TYPE_ON_DISCOVERY_REMOVE:
                self.discoveryListener?.onEntryRemoved(json: json)
                break;
            default:
                break;
            }
        }
    }

    /*
     * Initialize the library, set environment variables, and bind C ++ object to Java object.
     */
    public func dsmInit() -> Void {
        DSM_init(UnsafeMutableRawPointer(&dsmSelf), &dsmNative)
    }

    /*
     * Release the library and unbind the binding relationship, otherwise it may cause a memory leak.
     */
    public func dsmRelease() -> Void {
        DSM_release(UnsafeMutableRawPointer(&dsmSelf), &dsmNative)
    }

    deinit {
        dsmRelease()
    }

    /*
     * Start to discover the SMB server in the local area network.
     * When any SMB server is found or when the SMB server is disappears, a callback notification will be generated.
     */
    public func startDiscovery(_ timeOut: Int32 = 4) {
        DSM_startDiscovery(UnsafeMutableRawPointer(&dsmSelf), &dsmNative, timeOut);
    }

    /*
     * Stop discovering SMB servers in the LAN.
     */
    public func stopDiscovery() {
        DSM_stopDiscovery(UnsafeMutableRawPointer(&dsmSelf), &dsmNative)
    }

    /*
     * Resolve a Netbios name
     *
     * This function tries to resolves the given NetBIOS name with the
     * given type on the LAN, using broadcast queries. No WINS server is called.
     */
    public func resolve(_ name: String) -> String {
        let result: UnsafePointer<Int8>? = DSM_resolve(UnsafeMutableRawPointer(&dsmSelf), &dsmNative, name)
        if (result != nil) {
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
        let result: UnsafePointer<Int8>? = DSM_inverse(UnsafeMutableRawPointer(&dsmSelf), &dsmNative, address)
        if (result != nil) {
            let name = String(cString: result!)
            return name
        }
        return ""
    }

    /*
     * Login to an SMB server, if login fails, it will try to log in again with Gust identity.
     */
    public func login(_ host: String, _  loginName: String, _  password: String) -> Int32 {
        return DSM_login(UnsafeMutableRawPointer(&dsmSelf), &dsmNative, host, loginName, password)
    }

    /*
     * Exit from an SMB server.
     *
     * @return 0 = SUCCESS OR ERROR
     */
    public func logout() -> Int32 {
        return DSM_logout(UnsafeMutableRawPointer(&dsmSelf), &dsmNative)
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
        let result: UnsafePointer<Int8>? = DSM_shareGetListJson(UnsafeMutableRawPointer(&dsmSelf), &dsmNative)
        if (result != nil) {
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
        return DSM_treeConnect(UnsafeMutableRawPointer(&dsmSelf), &dsmNative, name);
    }

    /*
     * Disconnect from a share
     *
     * @return 0 on success or a DSM error code in case of error
     */
    public func treeDisconnect(_ tid: Int32) -> Int32 {
        return DSM_treeDisconnect(UnsafeMutableRawPointer(&dsmSelf), &dsmNative, tid);
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
    public func find(_ tid: Int32, _  pattern: String) -> String {
        let result: UnsafePointer<Int8>? = DSM_find(UnsafeMutableRawPointer(&dsmSelf), &dsmNative, tid, pattern)
        if (result != nil) {
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
    public func fileStatus(_ tid: Int32, _  path: String) -> String {
        let result: UnsafePointer<Int8>? = DSM_fileStatus(UnsafeMutableRawPointer(&dsmSelf), &dsmNative, tid, path)
        if (result != nil) {
            let fileStatus = String(cString: result!)
            return fileStatus
        }
        return ""
    }
}

public protocol DiscoveryListener {
    func onEntryAdded(json: String)
    func onEntryRemoved(json: String)
}

public class Log {

    public static func d(_ tag: String, _ message: String) {
        NSLog("%@ %@", tag, message)
    }
}
