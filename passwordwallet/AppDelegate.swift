//
//  AppDelegate.swift
//  Password Depot
//
//  Created by Li, Jonathan on 4/22/15.
//  Copyright (c) 2015 It21Learning. All rights reserved.
//

//logic:
//when the app starts, it check whether password file exists, if not, prompt user to set passcode and
//then create the empty password list
//if password file already exists,  first time starts the app will ask user to create the passcode

import UIKit
import GoogleMobileAds
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var passwordManager : PasswordManager!
    var logoutTimer : Timer?
    var bgTask :UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        passwordManager = PasswordManager();
        
        FIRApp.configure()
        GADMobileAds.configure(withApplicationID: "ca-app-pub-4348078921501765~4283309938")
        
        return true
    }
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        print("application handleopenurl");
        
        //first log out, then replace the file
        self.passwordManager.unloadPasswordFile()
        
        var error : NSError?
        passwordManager.copyPasswordFile( url.path, err: &error)
        if  let err = error {
            print("Error: \(err.localizedDescription)")
        }
        return true;
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
  
        print("applicationDidEnterBackground")

        if ( (UIApplication.shared.delegate as! AppDelegate).passwordManager.isPasswordFileUnlocked()){

            print("applicationDidEnterBackground settimer")

            //after device enters background, after waiting for 3 min, logout automatically
            bgTask = application.beginBackgroundTask(withName: "logout", expirationHandler: { () in
                //logout before expiration
                if let timer = self.logoutTimer {
                    print("applicationDidEnterBackground, expirationHandler: invalidate timer")

                    timer.invalidate()
                    self.logoutTimer = nil
                }
                self.unloadPassword()
            });
            
            print("applicationDidEnterBackground, start timer")

            logoutTimer = Timer.scheduledTimer(timeInterval: 1*60, target: self, selector: #selector(AppDelegate.unloadPassword), userInfo: nil, repeats: false)
        }
      }
    
    func unloadPassword() {
        print("unloadPassword set timer to nil")

        self.logoutTimer?.invalidate()
        self.logoutTimer = nil
        
        (UIApplication.shared).endBackgroundTask(self.bgTask)
        self.bgTask = UIBackgroundTaskInvalid;
        
        (UIApplication.shared.delegate as! AppDelegate).passwordManager.unloadPasswordFile()
        NotificationCenter.default.post(name: Notification.Name(rawValue: "passwordFileUnloaded"), object: nil)
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        print("applicationWillEnterForeground")

        if let timer = self.logoutTimer {
            print("applicationWillEnterForeground, invalidate timer")
            timer.invalidate()
            self.logoutTimer = nil
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("applicationDidBecomeActive")

        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

