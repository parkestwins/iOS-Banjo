//
//  PlatformDS.swift
//  Banjo
//
//  Created by Jarrod Parkes on 3/5/18.
//  Copyright © 2018 ParkesTwins. All rights reserved.
//

import Foundation
import UIKit

// MARK: - PlatformDS: NSObject, BaseTableDS

class PlatformDS: BaseTableDS {
    
    // MARK: Properties
    
    var platforms: [[Platform]] = [
        [
            .segaMasterSystem,
            .megaDrive,
            .segaCD,
            .sega32x,
            .segaSaturn,
            .dc
        ],
        [
            .nes,
            .snes,
            .n64,
            .gc,
            .wii,
            .wiiU,
            .nintendoSwitch
        ]
    ]
    
    // MARK: BaseTableDS
    
    override func dataSourceNumberOfSections(in tableView: UITableView) -> Int {
        return platforms.count
    }
    
    override func dataSourceNumberOfRowsInSection(in tableView: UITableView, section: Int) -> Int {
        switch state {
        case .normal, .ready:
            return platforms[section].count
        case .empty:
            return 1
        case .error, .loading:
            return 0
        }
    }
    
    override func dataSourceTableView(_ tableView: UITableView, cellForItemAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PlatformCell = tableView.dequeueReusableCellFromNib(forIndexPath: indexPath)
        
        let platform = platforms[indexPath.section][indexPath.row]
        cell.platformLabel.text = platform.name
        cell.nextImageView.image = #imageLiteral(resourceName: "right")
        
        return cell
    }
}
