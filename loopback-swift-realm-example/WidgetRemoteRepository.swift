//
//  WidgetRepository.swift
//  loopback-swift-realm-example
//
//  Created by Kevin Goedecke on 2/27/16.
//  Copyright © 2016 kevingoedecke. All rights reserved.
//

import LoopBack

class WidgetRemoteRepository : LBPersistedModelRepository     {
    override init() {
        super.init(className: "widgets")
    }
    class func repository() -> WidgetRemoteRepository {
        return WidgetRemoteRepository()
    }
}