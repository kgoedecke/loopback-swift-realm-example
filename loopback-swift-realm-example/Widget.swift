//
//  Widget.swift
//  loopback-swift-realm-example
//
//  Created by Kevin Goedecke on 2/26/16.
//  Copyright © 2016 kevingoedecke. All rights reserved.
//

import Foundation
import RealmSwift
import LoopBack

class Widget: Object {
    dynamic var name = ""
    dynamic var updated = NSDate(timeIntervalSince1970: 1)
    dynamic var remoteId = -1
    
    convenience init(remoteWidget: WidgetRemote) {
        self.init()
        self.name = remoteWidget.name
        self.updated = remoteWidget.updated
        self.remoteId = remoteWidget._id as! Int
    }
    
    func syncWithRemote() {
        // Widget was created offline and has never been synced
        if (self.remoteId == -1) {
            NSLog("Widget was created offline and has never been synced")
            let widgetRemote = AppDelegate.widgetRepository.modelWithDictionary(nil) as! WidgetRemote
            widgetRemote.name = self.name
            widgetRemote.updated = NSDate()
            widgetRemote.saveWithSuccess({ () -> Void in
                // Update local object with remote_id, updated and set synced to true
                let realm = try! Realm()
                try! realm.write    {
                    self.remoteId = widgetRemote._id as! Int
                    self.updated = widgetRemote.updated
                }
                }, failure: { (error: NSError!) -> Void in
                    // Offline, sync not possible
                    NSLog(error.description)
            })
        }
        // Has a remote_id and thus has already been synced at one point
        else {
            // Check if object has been deleted on Remote and if delete locally
            // For example if findById fails, notice to differenciate between
            // backend not reachable and id not found
            AppDelegate.widgetRepository.findById(self.remoteId, success: { (model: LBPersistedModel!) -> Void in
                // Maybe a new remote object with same ID was created in
                // that case overwrite local widget
                let remoteWidget = model as! WidgetRemote
                // Remote is indeed more recent
                if (remoteWidget.updated.compare(self.updated) != NSComparisonResult.OrderedAscending) {
                    try! self.realm!.write    {
                        self.name = remoteWidget.name
                        self.updated = remoteWidget.updated
                    }
                }
                // Local is more recent, update remote
                else {
                    remoteWidget.name = self.name
                    remoteWidget.updated = self.updated
                    remoteWidget.saveWithSuccess({ () -> Void in
                        NSLog("Successfully update remote widget")
                        }, failure: { (err: NSError!) -> Void in
                            NSLog(err.description)
                    })
                }
                }, failure: { (err: NSError!) -> Void in
                    // Error code -1011 means model with id not found
                    if (err.code == -1011) {
                        // Delete all with error code -1011
                        try! self.realm!.write {
                            self.realm!.delete(self)
                        }
                        NSLog("Remote widget not found, delete local widget")
                    }
            })
        }
    }
}