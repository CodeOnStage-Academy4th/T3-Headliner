//
//  SongService.swift
//  Headliner
//
//  Created by Soop on 8/8/25.
//

import Foundation
import Moya
import SwiftUI

protocol SongServiceType {
//    func getLatestSongs() async throws -> SongResponse // 다른 모델 써야 함
    func searchExactSongs(title: String, brand: String, limit: String, page: String) async throws -> SongResponse
    func searchContainsSongs(title: String, brand: String, limit: String, page: String) async throws -> SongResponse
}

class SongService: SongServiceType {
    
    private let jsonDecoder = JSONDecoder()
    let provider = MoyaProvider<SongTarget>(plugins: [MoyaLoggingPlugin()])
    
    func searchExactSongs(title: String, brand: String, limit: String, page: String) async throws -> SongResponse {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.searchExact(title, brand, limit, page)) { result in
                switch result {
                case .success(let response):
                    do {
                        let decodedResponse = try self.jsonDecoder.decode(SongResponse.self, from: response.data)
                        continuation.resume(returning: decodedResponse)
                    } catch {
                        continuation.resume(throwing: error)
                        print("정확 검색 실패")
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                    print("정확 검색 네트워킹 실패")
                }
            }
        }
    }
    
    func searchContainsSongs(title: String, brand: String, limit: String, page: String) async throws -> SongResponse {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.searchContains(title, brand, limit, page)) { result in
                switch result {
                case .success(let response):
                    do {
                        let decodedResponse = try self.jsonDecoder.decode(SongResponse.self, from: response.data)
                        continuation.resume(returning: decodedResponse)
                    } catch {
                        continuation.resume(throwing: error)
                        print("포함 검색 실패")
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                    print("포함 검색 네트워킹 실패")
                }
            }
        }
    }
}

