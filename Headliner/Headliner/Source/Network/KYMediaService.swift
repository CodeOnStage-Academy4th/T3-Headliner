import Foundation
import SwiftSoup

class KYMediaService: KaraokeServiceType {
    
    private let baseURL = "https://kysing.kr/search/"
    private let matcher = KaraokeMatcher.shared
    
    func fetchKaraokeNumber(title: String, artist: String) async throws -> String? {
        // 검색어 생성
        let searchTerm = matcher.stripQualifiers(matcher.stripParenthetical(title))
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: #",\s*[^,]*$"#, with: "", options: .regularExpression)

        if searchTerm.isEmpty {
            return nil
        }
        
        // 네트워크 요청
        guard var components = URLComponents(string: baseURL) else { return nil }
        components.queryItems = [
            URLQueryItem(name: "category", value: "2"), // 곡명 검색
            URLQueryItem(name: "keyword", value: searchTerm)
        ]
        guard let url = components.url else { return nil }
        
        print("[KYMediaService] Requesting URL: \(url)")
        
        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { return nil }
        guard let html = String(data: data, encoding: .utf8) else { return nil }
        
        // 검색 결과에서 가장 일치하는 곡 찾기
        let songs = try parseHTML(html: html)
        
        let matchedSong = matcher.findBestMatch(songs: songs, originalTitle: title, originalArtist: artist)
        return matchedSong?.number
    }
    
    private func parseHTML(html: String) throws -> [KaraokeSong] {
        let doc: Document = try SwiftSoup.parse(html)
        let rows = try doc.select("ul.search_chart_list")
        
        var songs: [KaraokeSong] = []
        for row in rows {
            let number = try row.select("li.search_chart_num").text()
            if number.isEmpty { continue }
            
            let title = try row.select("li.search_chart_tit span.tit").first()?.text() ?? ""
            let artist = try row.select("li.search_chart_tit span.mo-art").text()
            
            if !title.isEmpty {
                songs.append(KaraokeSong(number: number, title: title, artist: artist))
            }
        }
        return songs
    }
}
