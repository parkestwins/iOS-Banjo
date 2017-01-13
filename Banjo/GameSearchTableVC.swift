//
//  GameSearchTableVC.swift
//  Banjo
//
//  Created by Jarrod Parkes on 12/23/16.
//  Copyright © 2016 ParkesTwins. All rights reserved.
//

import UIKit
import RealmSwift

// MARK: - GameSearchTableVC: RealmSearchViewController

class GameSearchTableVC: RealmSearchVC {
    
    // MARK: Properties
    
    private let reuseIdentifier = "gameCell"
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = false
        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: RealmConstants.updateNotification), object: nil, queue: nil) { notification in
            self.tableView.reloadData()
        }
        setupUI()
    }
    
    // MARK: Deinitializer
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Setup
    
    private func setupUI() {
        title = "N64 Games"
        let gameCellNib = UINib(nibName: "GameCell", bundle: nil)
        tableView.register(gameCellNib, forCellReuseIdentifier: reuseIdentifier)
    }
    
    // MARK: Actions
    
    @IBAction func toStartScreen(_ sender: Any) {
        let _ = navigationController?.popViewController(animated: true)
    }

    // MARK: RealmSearchResultsDataSource
    
    override func searchViewController(controller: RealmSearchVC, cellForObject object: Object, atIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath as IndexPath)
        if let game = object as? Game, let gameCell = cell as? GameCell {
            gameCell.titleLabel.text = game.title
            if let firstRelease = game.releases.first {
                var developerPublisherText = ""
                if let developer = firstRelease.developer {
                    developerPublisherText = developer + " / " + firstRelease.publisher
                } else {
                    developerPublisherText = firstRelease.publisher
                }
                gameCell.developerPublisherLabel.text = developerPublisherText
            } else {
                gameCell.developerPublisherLabel.text = "Unreleased"
            }
        }
        return cell
    }
    
    // MARK: RealmSearchResultsDelegate
    
    override func searchViewController(controller: RealmSearchVC, didSelectObject anObject: Object, atIndexPath indexPath: IndexPath) {
        if let game = anObject as? Game {
            performSegue(withIdentifier: "showDetail", sender: game)
        }
    }
    
    // MARK: Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let game = sender as? Game, let gameDetailVC = segue.destination as? GameDetailVC, segue.identifier == "showDetail" {
            gameDetailVC.game = game
                        
            if let usRegion = RealmClient.shared.realm.objects(Region.self).filter("abbreviation = 'US'").first {
                let sortedReleases = game.releases.sorted(byKeyPath: "date")
                let usReleases = game.releases.filter("region == %@", usRegion).sorted(byKeyPath: "date")
                
                if usReleases.count > 0 {
                    gameDetailVC.selectedRelease = usReleases.first
                } else {
                    gameDetailVC.selectedRelease = sortedReleases.first
                }
            } else {
                gameDetailVC.selectedRelease = game.releases.first
            }
        }
    }
}
