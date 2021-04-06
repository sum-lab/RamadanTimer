//
//  AppDelegate.swift
//  RamadanTimer
//
//  Created by Sumayyah on 24/09/16.
//  Copyright © 2016 Sumayyah. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    let center = UNUserNotificationCenter.current()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // set default settings
        if !UserDefaults.standard.bool(forKey: "hasLaunchedOnce") {
            UserDefaults.standard.set(true, forKey: "hasLaunchedOnce")
            UserSettings.shared.setDefaults()
            saveCities()
        }
        
        // Ask for authorization for notifications

        let options: UNAuthorizationOptions = [.alert, .sound]
        center.requestAuthorization(options: options) {
            (granted, error) in
            UserDefaults.standard.set(granted, forKey: "notifsAuthorized")
            if !granted {
                UserSettings.shared.notifications = false
            }
        }
        center.delegate = self
        
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
        // check if notifications authorization has changed
        center.getNotificationSettings(completionHandler: {(settings) in
            let authorized = settings.authorizationStatus == .authorized
            if !authorized {
                UserSettings.shared.notifications = false
            }
            UserDefaults.standard.set(authorized, forKey: "notifsAuthorized")
        })
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Notifications
    
    /// Schedules new notifications while deleting old notifications that are not needed
    func scheduleNotifications(requests: [UNNotificationRequest]) {
        let identifiersForNew: [String] = requests.map {$0.identifier}
        
        center.getPendingNotificationRequests { pendingRequests in
            // Get all pending notification requests and filter only the ones that will not be replaced
            let identifiersForPending = pendingRequests.map {$0.identifier}
            let toDelete = pendingRequests.filter { !identifiersForNew.contains($0.identifier)}
            let requestsToAdd = requests.filter {
                !identifiersForPending.contains($0.identifier)
            }
            let identifiersToDelete = toDelete.map {$0.identifier}
            
            // Delete notifications that will not be replaced
            self.center.removePendingNotificationRequests(withIdentifiers: identifiersToDelete)
            
            // Add all new requests
            for request in requestsToAdd {
                self.center.add(request, withCompletionHandler: { (error) in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                })
            }
        }
    }
    
    /// create and return notification request with given title, sound and date
    func createNotificationRequest(title: String, sound: String, date: Date) -> UNNotificationRequest? {
        let today = Date()
        
        if today < date {
            let content = UNMutableNotificationContent()
            content.body = title
            content.sound = UNNotificationSound.init(named: convertToUNNotificationSoundName(sound))
            let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
            // set date string as identifier
            let identifier = stringFromDate(formatString: "MM-dd-yyyy-HH-mm-ss", date: date)!
            let request = UNNotificationRequest(identifier: identifier,
                                                content: content, trigger: trigger)
            return request
        }
        return nil
    }
    
    /// Notification center delegate
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.sound, .alert])
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "RamadanTimer")
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
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
    
    /// Save cities information to Core Data. Runs asynchronously in background
    func saveCities(){
        persistentContainer.performBackgroundTask { managedContext in
            // read file into string
            let fileURL = Bundle.main.url(forResource: "Cities", withExtension: "csv")!
            let fileString = try! String(contentsOf: fileURL, encoding: .utf8)
            let allLines = fileString.components(separatedBy: "\n")
            for line in allLines {
                if line != "" {
                    let components = line.components(separatedBy: ",")
                    // 2
                    let entity = NSEntityDescription.entity(forEntityName: "City",
                                                            in: managedContext)!
                    let city = NSManagedObject(entity: entity,
                                               insertInto: managedContext) as! City
                    
                    // 3
                    city.setValue(components[0], forKeyPath: "name")
                    city.setValue(Double(components[2]), forKeyPath: "latitude")
                    city.setValue(Double(components[3]), forKeyPath: "longitude")
                    city.setValue(components[5], forKeyPath: "country")
                }
                do {
                    try managedContext.save()
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
            }
        }
    }
    
    /// get cities from core data
    func getCities() -> [NSManagedObject]? {
        let managedContext = persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "City")
        
        do {
            let cities = try managedContext.fetch(fetchRequest)
            return cities
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return nil
        }
    }
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUNNotificationSoundName(_ input: String) -> UNNotificationSoundName {
	return UNNotificationSoundName(rawValue: input)
}
