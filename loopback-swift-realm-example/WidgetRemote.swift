//
//  WidgetRemote.swift
//  loopback-swift-realm-example
//
//  Created by Kevin Goedecke on 2/27/16.
//  Copyright © 2016 kevingoedecke. All rights reserved.
//

import LoopBack

class WidgetRemote : LBPersistedModel {
    var name: String!
    var updated: NSDate!
}