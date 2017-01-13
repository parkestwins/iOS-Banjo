//
//  RealmClient.swift
//  Banjo
//
//  Code snippet by Hector Matos.
//  Hector: krakendev.io/blog/the-right-way-to-write-a-singleton/
//
//  Created by Jarrod Parkes on 01/07/16.
//  Copyright © 2017 ParkesTwins. All rights reserved.
//

import Realm
import Foundation
import RealmSwift
import Realm.Dynamic

// MARK: - RealmClient

class RealmClient {

    // MARK: Properties
    
    var token: RLMNotificationToken?
    
    // MARK: Computed Properties
    
    var realm: Realm {
        return try! Realm(configuration: Realm.Configuration.defaultConfiguration)
    }
    var rlmRealm: RLMRealm {
        let configuration = toRLMConfiguration(configuration: Realm.Configuration.defaultConfiguration)
        return try! RLMRealm(configuration: configuration)
    }
    var isSynced: Bool {
        return SyncUser.current != nil
    }
    
    // MARK: Sync Realm
    
    func syncRealm(completionHandler: @escaping (_ synced: Bool, _ error: Error?) -> Void) {
        if realmSynced() {
            // we're already synced before
            completionHandler(true, nil)
        } else {
            // never synced before, must login to sync
            logInWithCompletionHandler(completionHandler)
        }
    }
    
    func resyncRealm(completionHandler: @escaping (_ synced: Bool, _ error: Error?) -> Void) {
        SyncUser.current?.logOut()
        syncRealm(completionHandler: completionHandler)
    }
    
    private func realmSynced() -> Bool {
        // if sync user is authenticated and realm is populated, then user is already synced
        if let user = SyncUser.current, realm.objects(Game.self).count > 0 {
            setConfigurationAndTokenWithUser(user)
            return true
        }
        // otherwise, user is not synced, try again
        return false
    }
    
    private func setConfigurationAndTokenWithUser(_ user: SyncUser) {
        Realm.Configuration.defaultConfiguration = Realm.Configuration(syncConfiguration: SyncConfiguration(user: user, realmURL: URL(string: RealmConstants.liveRealm)!))
        
        token = realm.addNotificationBlock { _ in
            NotificationCenter.default.post(name: Notification.Name(rawValue: RealmConstants.updateNotification), object: nil)
        }
    }
    
    private func logInWithCompletionHandler(_ completionHandler: @escaping (_ synced: Bool, _ error: Error?) -> Void) {
        
        SyncUser.logIn(with: .usernamePassword(username: RealmConstants.username, password: RealmConstants.password, register: false), server: URL(string: RealmConstants.liveServer)!) { user, error in
            
            guard let user = user else {
                completionHandler(false, error)
                return
            }
            
            DispatchQueue.main.async {
                self.setConfigurationAndTokenWithUser(user)
                completionHandler(true, nil)
            }
        }
    }
    
    // MARK: Utility
    
    func toRLMConfiguration(configuration: Realm.Configuration) -> RLMRealmConfiguration {
        let rlmConfiguration = RLMRealmConfiguration()
        if configuration.fileURL != nil {
            rlmConfiguration.fileURL = configuration.fileURL
        }
        
        if configuration.inMemoryIdentifier != nil {
            rlmConfiguration.inMemoryIdentifier = configuration.inMemoryIdentifier
        }
        
        if configuration.syncConfiguration != nil {
            rlmConfiguration.syncConfiguration = RLMSyncConfiguration(user: (configuration.syncConfiguration?.user)!, realmURL: (configuration.syncConfiguration?.realmURL)!)
        }
        rlmConfiguration.encryptionKey = configuration.encryptionKey
        rlmConfiguration.readOnly = configuration.readOnly
        rlmConfiguration.schemaVersion = configuration.schemaVersion
        return rlmConfiguration
    }
        
    // MARK: Singleton
    
    static let shared = RealmClient()
    
    // private init() prevents others from using the default '()' initializer
    private init() {}
    
    deinit {
        token?.stop()
    }
}
