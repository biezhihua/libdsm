//
//  libdsm_iosTests.swift
//  libdsm_iosTests
//
//  Created by biezhihua on 2020/1/23.
//  Copyright © 2020 biezhihua. All rights reserved.
//

import XCTest
@testable import libdsm_ios

class libdsm_iosTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func initOrRelase() {
        let dsm = Dsm()
        dsm.dsmInit()
        dsm.dsmRelease()
    }

    struct MyDiscoveryListener : DiscoveryListener {
        
        func onEntryAdded(json: String) {
            Log.d("Main", "onEntryAdded \(json)")
        }
        
        func onEntryRemoved(json: String) {
            Log.d("Main", "onEntryRemoved \(json)")
        }
        
    }
    
    func discoverySmbServer() {
        let dsm = Dsm()
        dsm.dsmInit()

        dsm.discoveryListener = MyDiscoveryListener()
        
        dsm.startDiscovery()
        dsm.stopDiscovery()

        dsm.dsmRelease()
    }

    func loginOrlogoutSmbServer() {
        let dsm = Dsm()
        dsm.dsmInit()

        dsm.login("xxx-pc", "account-name", "password")

        dsm.logout()

        dsm.dsmRelease()()
    }

    func getSmbServerShareList() {
        let dsm = Dsm()
        dsm.dsmInit()

        dsm.login("xxx-pc", "account-name", "password")

        let shareJson = dsm.getShareList()

        dsm.logout()

        dsm.dsmRelease()
    }

    func connectToSmbServerShare() {
        let dsm = Dsm()
        dsm.dsmInit()

        dsm.login("xxx-pc", "account-name", "password")

        let shareNamesJson = dsm.getShareList()

        let tid = dsm.treeConnect("share-name")

        dsm.treeDisconnect(tid)

        dsm.logout()

        dsm.dsmRelease()
    }

    func findRootFilesFromSmbServer() {
        let dsm = Dsm()
        dsm.dsmInit()

        dsm.login("xxx-pc", "account-name", "password")

        let shareNamesJson = dsm.getShareList()

        let tid = dsm.treeConnect("share-name")

        let filesJson = dsm.find(tid, "\\*")

        dsm.treeDisconnect(tid)

        dsm.logout()

        dsm.dsmRelease()
    }

    func findDirectoryFilesFromSmbServer() {
        let dsm = Dsm()
        dsm.dsmInit()

        dsm.login("xxx-pc", "account-name", "password")

        let shareNamesJson = dsm.getShareList()

        let tid = dsm.treeConnect("share-name")

        let filesJson = dsm.find(tid, "\\Directory\\*")

        dsm.treeDisconnect(tid)

        dsm.logout()

        dsm.dsmRelease()
    }

    func queryFileStatusFromSmbServer() {
        let dsm = Dsm()
        dsm.dsmInit()

        dsm.login("xxx-pc", "account-name", "password")

        let shareNamesJson = dsm.getShareList()

        let tid = dsm.treeConnect("share-name")

        let fileStatusJson = dsm.fileStatus(tid, "\\Directory\\Directory\\File.Extension")

        dsm.treeDisconnect(tid)

        dsm.logout()

        dsm.dsmRelease()
    }

}
