//
//  Widget.swift
//  loopback-swift-realm-example
//
//  Created by Kevin Goedecke on 2/26/16.
//  Copyright © 2016 kevingoedecke. All rights reserved.
//

import Foundation
import RealmSwift

class Widget: Object {
    dynamic var name = ""
    dynamic var updated = NSDate(timeIntervalSince1970: 1)
    dynamic var synced = false
    dynamic var remoteId = 0
}