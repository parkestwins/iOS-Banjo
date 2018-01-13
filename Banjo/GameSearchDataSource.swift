//
//  GameSearchDataSource.swift
//  Banjo
//
//  Created by Jarrod Parkes on 1/12/18.
//  Copyright © 2018 ParkesTwins. All rights reserved.
//

import Foundation
import UIKit

// MARK: - GameSearchDataSourceDelegate

protocol GameSearchDataSourceDelegate {
    func gameSearchDataSourceDidFetchGames(gameSearchDataSource: GameSearchDataSource)
    func gameSearchDataSource(_ gameSearchDataSource: GameSearchDataSource, didFailWithError error: Error)
}

// MARK: - GameSearchDataSource: NSObject, BaseTableDataSource

class GameSearchDataSource: BaseTableDataSource {
    
    // MARK: Properties
    
    var games = [GamePartial]()
    var delegate: GameSearchDataSourceDelegate?
    
    // MARK: Fetch List
    
    func fetchList(forQuery query: String) {
        IGDBService.shared.load(IGDBRequest.searchGames(query), type: [GamePartial].self) { (parse) in
            guard !parse.isCancelled else { return }
            
            if let results = parse.result as? [GamePartial] {
                self.games = results
                
                if self.games.count == 0 {
                    self.state = .empty
                } else {
                    self.state = .normal
                }
                
                self.delegate?.gameSearchDataSourceDidFetchGames(gameSearchDataSource: self)
            } else {
                if let error = parse.error {
                    self.delegate?.gameSearchDataSource(self, didFailWithError: error)
                } else {
                    // FIXME: remove this code path
                    print("unknown error!")
                }
            }
        }
    }
    
    // MARK: Helpers
    
    func cancelSearch() {
        IGDBService.shared.cancelSearch()
    }
    
    // MARK: BaseTableDataSource
    
    override func dataSourceNumberOfRowsInSection(in tableView: UITableView) -> Int {
        switch state {
        case .normal, .ready:
            return games.count
        case .empty:
            return 1
        case .error, .loading:
            return 0
        }
    }
    
    override func dataSourceTableView(_ tableView: UITableView, cellForItemAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GameCell = tableView.dequeueReusableCellFromNib(forIndexPath: indexPath)
        
        let game = games[indexPath.row]
        cell.titleLabel.text = game.name
        let dateString = BanjoFormatter.shared.formatDateFromTimeIntervalSince1970(value: game.firstReleaseDate)
        cell.releaseDateLabel.text = dateString
        cell.nextImageView.image = #imageLiteral(resourceName: "right")
        
        return cell
    }
    
    override func dataSourceTableView(_ tableView: UITableView, emptyCellForItemAt indexPath: IndexPath) -> UITableViewCell {
        let cell: EmptyCell = tableView.dequeueReusableCellFromNib(forIndexPath: indexPath)
        
        cell.messageLabel.text = "Start by searching for a game..."
                
        return cell
    }
}
