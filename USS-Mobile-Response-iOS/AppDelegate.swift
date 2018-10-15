//
//  AppDelegate.swift
//  USS-Mobile-Response-iOS
//
//  Created by Andrew Tsai on 5/31/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation
import Foundation

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?
    var orientationLock = UIInterfaceOrientationMask.all
    var audioSession: AVAudioSession?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        printDocDir()
        printImportDir()
        printTmpDir()
        
        let fileManager: FileManager = FileManager.default
        let docDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        let tempDocDir = docDir!.appendingPathComponent("tmp")
        
        if(!fileManager.fileExists(atPath: tempDocDir.relativePath))
        {
            do
            {
                try fileManager.createDirectory(at: tempDocDir, withIntermediateDirectories: false, attributes: nil)
            }
            catch
            {
                print(error)
            }
        }
        
        audioSession = AVAudioSession.sharedInstance()
        do
        {
            try audioSession!.setCategory(AVAudioSessionCategoryPlayAndRecord, with: AVAudioSessionCategoryOptions.defaultToSpeaker)
        }
        catch
        {
            print("Setting up audio session failed")
        }
        
        // Override point for customization after application launch.
        if UserDefaults.standard.bool(forKey: "isLoggedIn") {
            let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let mainNavigationController = mainStoryboard.instantiateViewController(withIdentifier: "MainNavigationController") as? MainNavigationController
            window?.rootViewController = mainNavigationController
            window?.makeKey()
        }
        else {
            if let loginViewController = window?.rootViewController as? LoginViewController {
                loginViewController.plistController = PlistController()
            }
        }
        return true
    }

    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask
    {
        return self.orientationLock
    }
    
    struct AppUtility
    {
        static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
            if let delegate = UIApplication.shared.delegate as? AppDelegate {
                delegate.orientationLock = orientation
            }
        }
        
        static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
            self.lockOrientation(orientation)
            UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
        }
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
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "USS-Mobile-Response-iOS")
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
    
    func saveContext ()
    {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do
            {
                try context.save()
            }
            catch
            {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool
    {
        let fileManager: FileManager = FileManager.default
        let docDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        let tempDir = docDir?.appendingPathComponent("tmp/\(url.lastPathComponent)")
        
        do
        {
            let pdfFile: Data = try Data(contentsOf: url)
            
            do
            {
                try pdfFile.write(to: tempDir!)
                NotificationCenter.default.post(name: Notification.Name("New data"), object: nil)
                
            }
            catch
            {
                print(error)
                return false
            }
        }
        catch
        {
            print(error)
            return false
        }

        return true
    }
}

