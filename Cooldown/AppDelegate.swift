//
//  AppDelegate.swift
//  Cooldown
//
//  Created by Matt Jones on 8/8/17.
//  Copyright © 2017 Matt Jones. All rights reserved.
//

import UIKit
import UserNotifications
import WatchConnectivity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window?.tintColor = UIColor(red: 0.1, green: 0.8, blue: 0.1, alpha: 1)
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if !granted, let error = error { print(error) }
        }
        
        if WCSession.isSupported() {
            WCSession.default().delegate = self
            WCSession.default().activate()
        }
        
        return true
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error { print(error) }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        guard let data = message["cooldown"] as? Data,
            let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any],
            let interval = message["cooldownInterval"] as? TimeInterval else
        {
            return
        }
        
        State.shared.cooldown = Cooldown(json: json)
        State.shared.cooldownInterval = interval
        
        DispatchQueue.main.async {
            if let controller = self.window?.rootViewController as? ViewController {
                controller.updateUI()
            }
        }
    }
    
}
