//
//  StartVC.swift
//  Banjo
//
//  Created by Jarrod Parkes on 12/23/16.
//  Copyright © 2016 ParkesTwins. All rights reserved.
//

import UIKit

// MARK: - StartVCState

enum StartVCState {
    case startSync
    case cannotSync
    case synced
    case failedAuth
}

// MARK: - StartVC: UIViewController

class StartVC: UIViewController {
    
    // MARK: Properties
    
    var reachability = Reachability.networkReachabilityForInternetConnection()
    
    // MARK: Outlets
    
    @IBOutlet weak var searchGamesButton: UIButton!    
    @IBOutlet weak var syncStatusLabel: UILabel!
    @IBOutlet weak var networkActivityIndicator: UIActivityIndicatorView!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // start listening for reachability changes
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityDidChange(_:)), name: NSNotification.Name(rawValue: ReachabilityDidChangeNotificationName), object: nil)
        _ = reachability?.startNotifier()
        
        syncRealm()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: Actions
    
    @IBAction func startSearching(_ sender: Any) {
        performSegue(withIdentifier: AppConstants.Segues.login, sender: self)
    }
    
    // MARK: Setup UI
    
    private func setupUI(forState: StartVCState) {
        switch (forState) {
        case .startSync:
            syncStatusLabel.text = ""
            activityIndicatorSetEnabled(true)
            searchGamesButtonSetEnabled(false, withText: AppConstants.Strings.startInitDatabase)
        case .cannotSync:
            syncStatusLabel.text = AppConstants.Strings.resolveSync
            activityIndicatorSetEnabled(false)
            searchGamesButtonSetEnabled(false, withText: AppConstants.Strings.startErrorInit)
            displayDismissAlert(title: AppConstants.Strings.failSync, message: AppConstants.Strings.resolveSync, dismissHandler: nil)
        case .synced:
            syncStatusLabel.text = ""
            activityIndicatorSetEnabled(false)
            searchGamesButtonSetEnabled(true, withText: AppConstants.Strings.startSearchDatabase)
        case .failedAuth:
            syncStatusLabel.text = AppConstants.Strings.resolveAuthError
            activityIndicatorSetEnabled(false)
            searchGamesButtonSetEnabled(false, withText: AppConstants.Strings.startErrorInit)
            displayDismissAlert(title: AppConstants.Strings.failAuth, message: AppConstants.Strings.resolveAuthError, dismissHandler: nil)
        }
    }
    
    private func searchGamesButtonSetEnabled(_ enabled: Bool, withText: String) {
        searchGamesButton.setTitle(withText, for: (enabled) ? .normal : .disabled)
        searchGamesButton.isEnabled = enabled
    }
    
    private func activityIndicatorSetEnabled(_ enabled: Bool) {
        networkActivityIndicator.isHidden = !enabled
        if enabled {
            networkActivityIndicator.startAnimating()
        } else {
            networkActivityIndicator.stopAnimating()
        }
    }
    
    // MARK: Deinitializer
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        reachability?.stopNotifier()
    }
    
    // MARK: Reachability
    
    func reachabilityDidChange(_ notification: Notification) {
        guard let reachability = reachability else { return }
        if reachability.isReachable {
            // if never synced before, try syncing for the first time
            if !RealmClient.shared.isSynced {
                syncRealm()
            } else {
                // otherwise, resync (logout, then login) to continue getting updates
                RealmClient.shared.resyncRealm { (synced, error) in
                    if let error = error {
                        // fail silently, this could be called from anywhere
                        print(error)
                    }
                    if synced == true {
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: Notification.Name(rawValue: RealmConstants.updateNotification), object: nil)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: Sync Realm
    
    private func syncRealm() {
        if let _ = RealmClient.shared.token {
            setupUI(forState: .synced)
        } else {
            setupUI(forState: .startSync)
            RealmClient.shared.syncRealm { (synced, error) in
                DispatchQueue.main.async {
                    if let _ = error as? RealmClientError, synced == false {
                        self.setupUI(forState: .failedAuth)
                    } else if let _ = error {
                        self.setupUI(forState: .cannotSync)
                    } else {
                        self.setupUI(forState: .synced)
                    }
                }
            }
        }
    }
}
