//
//  IGDBRequest.swift
//  ModelExplorer
//
//  Created by Jarrod Parkes on 1/8/18.
//  Copyright © 2018 ParkesTwins. All rights reserved.
//

import Foundation

// MARK: - IGDBRequest

public enum IGDBRequest {
    case getGame(Int)
    case getGameExpanded(Int)
    case searchGames(String, Platform, Region)
    
    public var method: HTTPMethod {
        switch self {
        case .getGame, .getGameExpanded, .searchGames:
            return .get
        }
    }
    
    public var path: String {
        switch self {
        case .getGame(let id), .getGameExpanded(let id):
            return "/games/\(id)"
        case .searchGames:
            return "/games/"
        }
    }
    
    public var urlRequest: URLRequest? {
        var request: URLRequest?
        
        if let url = components.url {
            var urlRequest = URLRequest(url: url)
            
            // add method
            urlRequest.httpMethod = method.rawValue
            
            // add headers
            for (key, value) in headers { urlRequest.addValue(value, forHTTPHeaderField: key) }
            
            // add http body
            if let httpBody = httpBody { urlRequest.httpBody = httpBody }
            
            request = urlRequest
        }
        
        return request
    }
    
    public var headers: [String: String] {
        var headers = [String: String]()
        
        headers["Accept"] = "application/json"
        headers["user-key"] = "c93283243a0b4f1135d087bdb7357848"

        return headers
    }
    
    public var components: URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api-endpoint.igdb.com"
        components.path = path
        components.queryItems = queryItems
        
        return components
    }
    
    public var queryItems: [URLQueryItem] {
        switch self {
        case .searchGames(let query, let platform, let region):
            return [
                URLQueryItem(name: "search", value: query),
                URLQueryItem(name: "filter[platforms][eq]", value: "\(platform.rawValue)"),
                URLQueryItem(name: "filter[release_dates.region][anyi]", value: "\(region.rawValue)"),
                URLQueryItem(name: "filter[esrb][exists]", value: ""),
                URLQueryItem(name: "limit", value: "50"),
                URLQueryItem(name: "fields", value: "name,first_release_date")
            ]
        case .getGameExpanded:
            return [
                URLQueryItem(name: "fields", value: "name,summary,genres,category,game_modes,first_release_date,release_dates,cover,esrb,screenshots"),
                URLQueryItem(name: "expand", value: "publishers,developers")
            ]
        default:
            return []
        }
    }
    
    public var httpBody: Data? {
        return nil
    }
}
