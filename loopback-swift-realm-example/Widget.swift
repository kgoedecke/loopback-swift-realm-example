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
    dynamic var updated = NSDate()
    let remoteId = RealmOptional<Int>()
    
    convenience init(remoteWidget: WidgetRemote) {
        self.init()
        self.name = remoteWidget.name
        self.updated = remoteWidget.updated
        self.remoteId.value = remoteWidget._id as? Int
    }
    
    private func updateLocalWidget(remoteWidget: WidgetRemote) {
        if (self.remoteId.value == remoteWidget._id as? Int || self.remoteId.value == nil) {
            try! realm!.write    {
                self.remoteId.value = remoteWidget._id as? Int
                self.name = remoteWidget.name
                self.updated = remoteWidget.updated
                NSLog("Successfully update local widget")
            }
        }
    }
    
    private func updateRemoteWidget(remoteWidget: WidgetRemote) {
        if (remoteWidget._id as? Int == self.remoteId.value || self.remoteId.value == nil) {
            remoteWidget.name = self.name
            remoteWidget.updated = self.updated
            remoteWidget.saveWithSuccess({ () -> Void in
                self.updateLocalWidget(remoteWidget)
                NSLog("Successfully update remote widget")
                }, failure: { (err: NSError!) -> Void in
                    NSLog(err.description)
            })
        }
    }
    
    func syncWithRemote() {
        // Widget was created offline and has never been synced
        if (self.remoteId.value == nil) {
            let widgetRemote = AppDelegate.widgetRepository.modelWithDictionary(nil) as! WidgetRemote
            self.updateRemoteWidget(widgetRemote)
        }
        // Has a remoteId and thus has already been synced
        else {
            AppDelegate.widgetRepository.findById(self.remoteId, success: { (model: LBPersistedModel!) -> Void in
                let remoteWidget = model as! WidgetRemote
                if (remoteWidget.updated.compare(self.updated) != NSComparisonResult.OrderedAscending) {
                    // Remote is more recent, update local
                    self.updateLocalWidget(remoteWidget)
                }
                else {
                    // Local is more recent, update remote
                    self.updateRemoteWidget(remoteWidget)
                }
                }, failure: { (err: NSError!) -> Void in
                    // If object was deleted on Remote (error -1011), then delete locally
                    if (err.code == -1011) {
                        NSLog("Remote widget not found, deleting local widget")
                        try! self.realm!.write {
                            self.realm!.delete(self)
                        }
                    }
            })
        }
    }
}