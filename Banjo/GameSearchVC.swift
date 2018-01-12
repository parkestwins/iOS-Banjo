//
//  GameSearchVC.swift
//  Banjo
//
//  Created by Jarrod Parkes on 12/23/16.
//  Copyright © 2016 ParkesTwins. All rights reserved.
//

import UIKit

// MARK: - GameSearchVC: UIViewController, NibLoadable

class GameSearchVC: UIViewController, NibLoadable {
    
    // MARK: Properties
    
    let gameSearchDataSource = GameSearchDataSource()
    
    // MARK: Outlets
    
    @IBOutlet weak var gamesTableView: UITableView!
    @IBOutlet weak var gamesSearchBar: UISearchBar!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.title = "Search"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "back-arrow"), style: .plain, target: self, action: #selector(back))
        
        gamesTableView.delegate = self
        gamesTableView.dataSource = gameSearchDataSource
        gameSearchDataSource.delegate = self
        gamesSearchBar.delegate = self
        
        gamesTableView.registerCellWithNib(GameCell.self, bundle: Bundle.main)
    }
    
    // MARK: Actions
    
    @objc func back() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - GameSearchVC: UISearchBarDelegate

extension GameSearchVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        // if query is empty, then we are done
        if searchText == "" {
            gameSearchDataSource.games = []
            gamesTableView?.reloadData()
            return
        }
        
        // if the search is still running, then cancel all the operations on the queue
        gameSearchDataSource.cancelSearch()
        
        // start new search
        gameSearchDataSource.fetchList(forQuery: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - GameSearchVC: GameSearchDataSourceDelegate

extension GameSearchVC: GameSearchDataSourceDelegate {
    func gameSearchDataSourceDidFetchGames(gameSearchDataSource: GameSearchDataSource) {
        gamesTableView.reloadData()
    }
    
    func gameSearchDataSource(_ gameSearchDataSource: GameSearchDataSource, didFailWithError error: Error) {
        displayAlert(title: "Error", message: error.localizedDescription, dismissHandler: nil)
    }
}

// MARK: - GameSearchVC: UIGestureRecognizerDelegate

extension GameSearchVC: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return gamesSearchBar.isFirstResponder
    }
}

// MARK: - GameSearchVC: UITableViewDelegate

extension GameSearchVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        if let controller = storyboard.instantiateViewController(withIdentifier: "GameDetailVC") as? GameDetailVC {
            
            let game = gameSearchDataSource.games[indexPath.row]
            
            IGDBService.shared.load(IGDBRequest.getGameExpanded(game.id), type: [Game].self) { (parse) in
                guard !parse.isCancelled else { return }
                
                if let results = parse.result as? [Game] {
                    controller.game = results[0]
                    self.navigationController?.pushViewController(controller, animated: true)
                } else {
                    print(parse.error ?? "error is nil!")
                }
            }
        }
    }
}