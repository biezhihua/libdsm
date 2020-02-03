import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        let urlString:String = "https://8.8.8.8"
        
        let url = URL(string: urlString)
        
        let request = URLRequest(url: url!)
        
        let config = URLSessionConfiguration.default
        
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: request) { (data,response,error) in
            
            
        }
        
        task.resume()
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
