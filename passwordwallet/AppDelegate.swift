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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var passwordManager : PasswordManager!
    var logoutTimer : NSTimer?
    var bgTask :UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        passwordManager = PasswordManager();
        
        return true
    }
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        println("application handleopenurl");
        var data = NSData(contentsOfURL: url)
        
        //first log out, then replace the file
        self.passwordManager.unloadPasswordFile()
        
        var error : NSError?
        passwordManager.copyPasswordFile( url.path!, err: &error)
        if  let err = error {
            println("Error: \(err.localizedDescription)")
        }
        return true;
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
  
    
        if ( (UIApplication.sharedApplication().delegate as! AppDelegate).passwordManager.isPasswordFileUnlocked()){

            //after device enters background, after waiting for 3 min, logout automatically
            bgTask = application.beginBackgroundTaskWithName("logout", expirationHandler: { () in
                //logout before expiration
                if let timer = self.logoutTimer {
                    println("applicationDidEnterBackground, expirationHandler: invalidate timer")

                    timer.invalidate()
                    self.logoutTimer = nil
                }
                self.unloadPassword()
            });
            
            println("applicationDidEnterBackground, start timer")

            logoutTimer = NSTimer.scheduledTimerWithTimeInterval(1*60, target: self, selector: Selector("unloadPassword"), userInfo: nil, repeats: false)
        }
      }
    
    func unloadPassword() {
        println("unloadPassword set timer to nil")

        self.logoutTimer = nil
        (UIApplication.sharedApplication()).endBackgroundTask(self.bgTask)
        self.bgTask = UIBackgroundTaskInvalid;
        
        (UIApplication.sharedApplication().delegate as! AppDelegate).passwordManager.unloadPasswordFile()
        NSNotificationCenter.defaultCenter().postNotificationName("passwordFileUnloaded", object: nil)
        
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        println("applicationWillEnterForeground")

        if let timer = self.logoutTimer {
            println("applicationWillEnterForeground, invalidate timer")
            timer.invalidate()
            self.logoutTimer = nil
        }
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

