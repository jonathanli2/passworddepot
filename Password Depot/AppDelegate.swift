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

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        passwordManager = PasswordManager();
        
        return true
    }
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
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
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

