//
//  BaseAPI.swift
//  Headliner
//
//  Created by Soop on 8/8/25.
//

import Foundation

enum BaseAPI: String {
    case base
    
    var apiDesc: String {
        switch self {
        case .base:
            return "https://api.manana.kr"
        }
    }
}
