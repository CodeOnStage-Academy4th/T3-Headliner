//
//  SongAPI.swift
//  Headliner
//
//  Created by Soop on 8/8/25.
//

import Foundation

public enum SongV1API {
    
    case latest             /// 최신곡
    
    public var apiDesc: String {
        switch self {
        case .latest:
            return "/karaoke.json"
        }
    }
}

public enum SongV2API {
    
    case searchExact(String, String, String, String)        /// 제목 완전 일치
    case searchContains(String, String, String, String)     /// 제목 부분 일치
    case searchTitleAndSinger                              // 가수, 제목
    
    public var apiDesc: String {
        switch self {
        case .searchExact(let title, let brand, let limit, let page):
            return "/v2/karaoke/search.json/"
            
        case .searchContains(let title, let brand, let limit, let page):
            return "/v2/karaoke/search.json"
            
        case .searchTitleAndSinger:
            return "/v2/karaoke/search.json"
        }
    }
}
