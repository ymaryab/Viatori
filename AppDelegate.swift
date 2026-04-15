//
//  AppDelegate.swift
//  Viatori
//
//  Created by Serkut Yegin on 27/10/2016.
//  Copyright © 2016 Proaegean Ar-Ge. All rights reserved.
//

import UIKit
import CoreData
import Fabric
import TwitterKit
import Crashlytics
import FBSDKCoreKit
import IQKeyboardManagerSwift
import AFNetworkActivityLogger

import OneSignal
import AWSS3
import AWSCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        /*
         Store the completion handler.
         */
        AWSS3TransferUtility.interceptApplication(application, handleEventsForBackgroundURLSession: identifier, completionHandler: completionHandler)
    }
   
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        #if DEBUG
            VTLanguageManager.sharedManager.initialize()
            //VTLanguageManager.sharedManager.debugInitialize()
            
            if let logger = AFNetworkActivityLogger.shared().loggers.first as? AFNetworkActivityLoggerProtocol {
                logger.level = .AFLoggerLevelDebug
            }
            
            AFNetworkActivityLogger.shared().startLogging()
            
        #else
            VTLanguageManager.sharedManager.initialize()
        #endif
        
        //MARK: Fabric & Twitter & Crashlytics
        Fabric.with([Crashlytics.self, Twitter.self])
        //MARK: Amazon
        VTAmazonManager.sharedManager.checkProfilePictureUploadNeeded()
        //MARK: Facebook
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        //MARK: Google+
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(String(describing: configureError))")
        GIDSignIn.sharedInstance().delegate = self
        
        //MARK: OneSignal
        
        OneSignal.initWithLaunchOptions(launchOptions, appId: "3f951b98-b623-4225-931e-9177f8f456a9", handleNotificationReceived: { (notification) in
            
            VTSingleton.shared.refreshNotifications()
            
        }, handleNotificationAction: { (result) in
            let payload: OSNotificationPayload? = result?.notification.payload
            var fullMessage: String? = payload?.body
            

            if payload?.additionalData != nil {
                var additionalData: [AnyHashable: Any]? = payload?.additionalData
                debugPrint(additionalData)
                if additionalData!["actionSelected"] != nil {
                    fullMessage = String( format:"%@\nPressed ButtonId:%@",fullMessage!,String(describing: additionalData!["actionSelected"]) )
                }
            }
            
            VTSingleton.shared.openNotificationForActivity()
            
            
            print(fullMessage ?? "")
        }, settings: [kOSSettingsKeyAutoPrompt : true, kOSSettingsKeyInAppAlerts: false])
   
        //OneSignal.initWithLaunchOptions(launchOptions, appId: "3f951b98-b623-4225-931e-9177f8f456a9")
        
        // Sync hashed email if you have a login system or collect it.
        //   Will be used to reach the user at the most optimal time of day.
        // OneSignal.syncHashedEmail(userEmail)
        
        //MARK: Keyboard Manager
        IQKeyboardManager.sharedManager().enable = false
        IQKeyboardManager.sharedManager().toolbarDoneBarButtonItemText = "TXT_COMMON_COMMON_DONE".localized()
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
        
        VTPeriodicLocationUpdater.sharedInstance.startPeriodicUpdateIfNeccesary()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        FBSDKAppEvents.activateApp()
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.      
        VTSingleton.shared.refreshNotifications()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        //self.saveContext()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if url.absoluteString.contains(VTConstants.Strings.facebookAppId) {
            return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String!, annotation: options[.annotation])
        } else {
            return GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String!, annotation: options[.annotation])
        }
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        NSLog("content available")
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        NSLog("content available")
        
    }

    // MARK: - Core Data stack

    /*lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Viatori")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }*/

}

extension AppDelegate : GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
    }
}

