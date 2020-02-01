//
//  ViewController.swift
//  example_ios
//
//  Created by biezhihua on 2020/1/23.
//  Copyright © 2020 biezhihua. All rights reserved.
//

import UIKit
import libdsm_ios

class ViewController: UIViewController {
    
    let dsm = Dsm()
    
    var tid: Int32 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dsm.discoveryListener = MyDiscoveryListener()
        
        Log.d("Main", "dsm \(dsm)")
        
        let urlString:String = "https://8.8.8.8"
    
        let url = URL(string: urlString)
        
        let request = URLRequest(url: url!)
        
        let config = URLSessionConfiguration.default
        
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: request) { (data,response,error) in
               
                 
        }
        
        task.resume()

    }
    
    struct MyDiscoveryListener : DiscoveryListener {
        
        func onEntryAdded(json: String) {
            Log.d("Main", "onEntryAdded \(json)")
        }
        
        func onEntryRemoved(json: String) {
            Log.d("Main", "onEntryRemoved \(json)")
        }
        
    }
    
    @IBAction func onCreate() {
        Log.d("Main", "onCreate")
         dsm.dsmInit()
    }
    
    @IBAction func onDestroy() {
        Log.d("Main", "onDestroy")
         dsm.dsmRelease()
    }
    
    @IBAction func onStartDiscovery() {
        Log.d("Main", "onStartDiscovery")
        dsm.startDiscovery()
    }
    
    @IBAction func onStopDiscovery() {
        Log.d("Main", "onStopDiscovery")
        dsm.stopDiscovery()
    }
    
    @IBAction func onLogin() {
        Log.d("Main", "onLogin")
        Log.d(
            "Main", "login() called with: name = [SMBSHARE] result = [\(dsm.login("BIEZHIHUA-PC","test","test"))]"
        )
    }
    
    @IBAction func onLogout() {
        Log.d("Main", "onLogout")
        Log.d("Main", "logout() called with: result = [\(dsm.logout())]")
    }
    
    @IBAction func onShareList() {
        Log.d("Main", "onShareList")
        Log.d("Main", "shareList() called with: result = [\(dsm.getShareList())]")
    }
    
    @IBAction func onConnect() {
        Log.d("Main", "onConnect")
        tid = dsm.treeConnect("F")
        Log.d("Main", "connect() called with: result = [\(tid)]")
    }
    
    @IBAction func onDisconnect() {
        Log.d("Main", "onDisconnect")
        let result = dsm.treeDisconnect(tid)
        tid = 0
        Log.d("Main", "disconnect() called with: result = [\(result)]")
    }
    
    @IBAction func onFind() {
        Log.d("Main", "onFind")
        Log.d("Main", "find() called with: result = [\(dsm.find(tid, "\\*"))]")
    }
    
    @IBAction func onOpenDir() {
        Log.d("Main", "onOpenDir")
        Log.d("Main", "openDir() called with: result = [\(dsm.find(tid, "\\splayer\\*"))]")
        Log.d("Main", "openDir() called with: result = [\(dsm.find(tid, "\\splayer\\splayer_soundtouch\\*"))]"
        )
    }
    
    @IBAction func onFileStatus() {
        Log.d("Main", "onFileStatus")
        Log.d("Main", "fileStatus() called with: result = [\(dsm.fileStatus(tid, "\\splayer\\splayer_soundtouch\\Test.cpp"))]"
        )
    }
}

