//
//  SongTarget.swift
//  Headliner
//
//  Created by Soop on 8/8/25.
//

import Foundation
import Moya

enum SongTarget {
    case latest
    case searchExact(String, String, String, String)        /// 제목 완전 일치
    case searchContains(String, String, String, String)     /// 제목 부분 일치
    case searchTitleAndSinger(String, String, String, String, String)
}

extension SongTarget: TargetType {
    var baseURL: URL {
        return URL(string: BaseAPI.base.apiDesc)!
    }
    
    var path: String {
        switch self {
        case .latest:
            return SongV1API.latest.apiDesc
            
        case .searchExact(let title, let brand, let limit, let page):
            return SongV2API.searchExact(title, brand, limit, page).apiDesc
            
        case .searchContains(let title, let brand, let limit, let page):
            return SongV2API.searchContains(title, brand, limit, page).apiDesc
            
        case .searchTitleAndSinger:
            return SongV2API.searchTitleAndSinger.apiDesc
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .latest,
                .searchExact,
                .searchContains,
                .searchTitleAndSinger:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .latest:
            return .requestPlain
            
        case .searchExact(
            let title,
            let brand,
            let limit,
            let page
        ):
            
            return .requestParameters(
                parameters: [
                    "title": title,
                    "brand": "tj",
                    "limit": limit,
                    "page": page
                ],
                encoding: URLEncoding.default
            )
            
        case .searchContains(
            let title,
            let brand,
            let limit,
            let page
        ):
            return .requestParameters(
                parameters: [
                    "title": title,
                    "titleLikeSide": "both",
                    "brand": "tj",
                    "limit": limit,
                    "page": page
                ],
                encoding: URLEncoding.default
            )
        case .searchTitleAndSinger(
            let title,
            let singer,
            let brand,
            let limit,
            let page
        ):
            let parameters = ["title": title,
                              "titleLikeSide": "both",
                              "singer": singer,
                              "singerLikeSide": "both",
                              "brand": brand,
                              "limit": limit,
                              "page": page
            ]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .latest,
                .searchExact,
                .searchContains,
                .searchTitleAndSinger:
            return [:]
        }
    }
}
