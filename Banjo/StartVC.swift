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
    case initial
    case cannotSync
    case synced
}

// MARK: - StartVC: UIViewController

class StartVC: UIViewController {
    
    // MARK: Properties
    
    var reachability = Reachability.networkReachabilityForInternetConnection()
    
    // MARK: Outlets
    
    @IBOutlet weak var searchGamesButton: UIButton!    
    @IBOutlet weak var syncStatusLabel: UILabel!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI(forState: .initial)
        
        // start listening for reachability changes
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityDidChange(_:)), name: NSNotification.Name(rawValue: ReachabilityDidChangeNotificationName), object: nil)
        _ = reachability?.startNotifier()
        
        syncRealm()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: Setup UI
    
    func setupUI(forState: StartVCState) {
        switch (forState) {
        case .initial:
            searchGamesButton.setTitle("Initializing Database...", for: .normal)
            searchGamesButton.isEnabled = false
        case .cannotSync:
            searchGamesButton.isEnabled = false
            searchGamesButton.setTitle("Could Not Initialize.", for: .disabled)
            syncStatusLabel.text = "Cannot sync.\nConnect to a network."
        case .synced:
            syncStatusLabel.text = ""
            searchGamesButton.setTitle("Search N64 Database...", for: .normal)
            searchGamesButton.isEnabled = true
        }
    }
    
    // MARK: Deinitializer
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        reachability?.stopNotifier()
    }
    
    // MARK: Actions
    
    @IBAction func startSearching(_ sender: Any) {
        performSegue(withIdentifier: "login", sender: self)
    }
    
    // MARK: Reachability
    
    func checkReachability() {
        guard let r = reachability else { return }
        if r.isReachable {
            syncRealm()
        } else {
            setupUI(forState: .cannotSync)
        }
    }
    
    func reachabilityDidChange(_ notification: Notification) {
        if RealmClient.shared.token == nil {
            checkReachability()
        }
    }
    
    // MARK: Sync Realm
    
    func syncRealm() {
        if let _ = RealmClient.shared.token {
            self.setupUI(forState: .synced)
        } else {
            RealmClient.shared.syncToRealm { error in
                DispatchQueue.main.async {
                    if let _ = error {
                        self.setupUI(forState: .cannotSync)
                    } else {
                        self.setupUI(forState: .synced)
                    }
                }
            }
        }
    }
}