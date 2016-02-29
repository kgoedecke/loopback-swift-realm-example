//
//  AppDelegate.swift
//  loopback-swift-realm-example
//
//  Created by Kevin Goedecke on 2/25/16.
//  Copyright © 2016 kevingoedecke. All rights reserved.
//

import UIKit
import LoopBack
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    static let adapter = LBRESTAdapter(URL: NSURL(string: "http://localhost:3000"))
    static let widgetRepository = adapter.repositoryWithClass(WidgetRemoteRepository) as! WidgetRemoteRepository
    
    static func syncAllWithRemote() {
        let realm = try! Realm()
        // Sort descending to remove potentially expired local widgets
        // that got removed from the backend before assigning new ids (avoids id conflicts)
        let widgets = realm.objects(Widget).sorted("remoteId", ascending: false)
        for widget in widgets {
            widget.syncWithRemote()
        }
        // Get new widgets from remote
        AppDelegate.widgetRepository.allWithSuccess({ (models: [AnyObject]!) -> Void in
            let widgets = models as! [WidgetRemote]
            for widget in widgets {
                let predicate = NSPredicate(format: "remoteId == %d", widget._id as! Int)
                let localWidget = realm.objects(Widget).filter(predicate)
                if (localWidget.count == 0) {
                    try! realm.write    {
                        let newWidget = Widget(remoteWidget: widget)
                        realm.add(newWidget)
                    }
                }
            }
            }) { (err: NSError!) -> Void in
                NSLog(err.description)
        }

    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        AppDelegate.syncAllWithRemote()
        return true
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

