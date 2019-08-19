//
//  AppDelegate.swift
//  miniPy
//
//  Created by Gui Andrade on 6/15/19.
//  Copyright © 2019 Gui Andrade. All rights reserved.
//

import UIKit
import iCustomPy

var appDelegate: AppDelegate {
    return UIApplication.shared.delegate as! AppDelegate
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var nav: UINavigationController?

    func load(_ mainView: MainViewController) {
        window = UIWindow(frame: UIScreen.main.bounds)
        nav = UINavigationController(rootViewController: mainView)
        nav?.isNavigationBarHidden = true
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
        
        let url = Bundle.main.url(forResource: "python36", withExtension: ".zip")
        let pypath = url?.path
        setenv("PYTHONPATH", pypath, 1)
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let mainView = MainViewController()
        if let launchUrl = launchOptions?[.url] as? NSURL {
            if launchUrl.startAccessingSecurityScopedResource() {
                let data = try? String(contentsOf: launchUrl.filePathURL!, encoding: .utf8)
                
                mainView.defaultCode = data ?? ""
                
                launchUrl.stopAccessingSecurityScopedResource()
            }
        }
        
        load(mainView)
        
        return true
    }
    
    func application(_ app: UIApplication, open launchUrl: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let mainView = MainViewController()
        let data = try? String(contentsOf: launchUrl, encoding: .utf8)
        mainView.defaultCode = data ?? ""
        load(mainView)

        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    

}

