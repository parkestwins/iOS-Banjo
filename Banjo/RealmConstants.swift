//
//  RealmConstants.swift
//  Banjo
//
//  Created by Jarrod Parkes on 1/7/17.
//  Copyright © 2017 ParkesTwins. All rights reserved.
//

// MARK: - RealmConstants

struct RealmConstants {
    
    static let anonymousPassword = "readonly"
    static let liveServer = "http://45.55.65.37:9080"
    static let liveRealm = "realm://45.55.65.37:9080/39c74ed4530102e9967ea983b0d9d10e/banjo"
    static let testServer = "http://127.0.0.1:9080"
    static let testRealm = "realm://127.0.0.1:9080/8c650c749b2a73d19163694ccbb36b96/banjo45"        
    static let updateNotification = "RealmClient.UpdateDetected"
    static let retryAttempts = 5    

    // MARK: Keys
    
    struct Keys {
        static let date = "date"
    }
    
    // MARK: Defaults
    
    struct Defaults {
        static let syncedBefore = "SyncedBefore"
        static let anonymousUsername = "AnonymousUsername"
    }
}
