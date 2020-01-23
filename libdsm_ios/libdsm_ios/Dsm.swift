import dsm_birdge

/*
* An Android wrapper for the libdsm library。
* https://videolabs.github.io/libdsm/
*/
class Dsm {

    var dsmFromNative: Int64 = 0

    var discoveryListener: DiscoveryListener? = nil
}

protocol DiscoveryListener {
    func onEntryAdded(json: String)
    func onEntryRemoved(json: String)
}
