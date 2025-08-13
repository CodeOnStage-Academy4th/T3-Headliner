import Foundation
import SwiftSoup

struct TJMediaSong: CustomStringConvertible {
    let number: String
    let title: String
    let artist: String
    
    var description: String {
        return "TJMediaSong(number: \"\(number)\", title: \"\(title)\", artist: \"\(artist)\")"
    }
}

class TJMediaService {
    
    private let baseURL = "https://www.tjmedia.com/song/accompaniment_search"
    
    func fetchKaraokeNumber(title: String, artist: String) async throws -> String? {
        // 검색어 생성
        let searchTerm = stripQualifiers(stripParenthetical(title))
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "")

        if searchTerm.isEmpty {
            return nil
        }
        
        // 네트워크 요청
        guard var components = URLComponents(string: baseURL) else { return nil }
        components.queryItems = [
            URLQueryItem(name: "strType", value: "0"), // 통합 검색
            URLQueryItem(name: "searchTxt", value: searchTerm)
        ]
        guard let url = components.url else { return nil }
        
        print("[TJMediaService] Requesting single URL: \(url)")
        
        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { return nil }
        guard let html = String(data: data, encoding: .utf8) else { return nil }
        
        // 검색 결과에서 가장 일치하는 곡 찾기
        let songs = try parseHTML(html: html)
        
        let matchedSong = findBestMatch(songs: songs, originalTitle: title, originalArtist: artist)
        return matchedSong?.number
    }
    
    private func parseHTML(html: String) throws -> [TJMediaSong] {
        let doc: Document = try SwiftSoup.parse(html)
        let rows = try doc.select("div.music-search-list ul.chart-list-area > li")
        
        var songs: [TJMediaSong] = []
        for row in rows {
            let number = try row.select("span.num2").text()
            if number.isEmpty { continue }
            
            let title = try row.select("li.title3 span, li.title2 span, li.title span").first()?.text() ?? ""
            let artist = try row.select("li.singer span, li.singer2 span").first()?.text() ?? ""
            
            if !title.isEmpty {
                songs.append(TJMediaSong(number: number, title: title, artist: artist))
            }
        }
        return songs
    }
    
    // MARK: - 문자열 정규화 및 유사도 비교
    
    private lazy var artistCanonicals: [String: String] = {
        let aliases: [String: [String]] = [
            "아이유": ["IU"], "방탄소년단": ["BTS"], "소녀시대": ["Girls' Generation", "SNSD"],
            "세븐틴": ["SEVENTEEN", "SVT"], "르세라핌": ["LE SSERAFIM", "LESSERAFIM"],
            "뉴진스": ["NewJeans", "New Jeans"], "에스파": ["aespa"], "스트레이 키즈": ["Stray Kids", "SKZ"]
        ]
        var map: [String: String] = [:]
        for (canonicalName, aliasList) in aliases {
            let normalizedCanonical = normalizeArtist(canonicalName)
            let allNames = [canonicalName] + aliasList
            for name in allNames {
                map[normalizeArtist(name)] = normalizedCanonical
            }
        }
        return map
    }()
    
    private func normalizeTitle(_ s: String) -> String {
        return baseNormalize(stripQualifiers(stripParenthetical(s)))
    }
    
    private func normalizeArtist(_ s: String) -> String {
        return baseNormalize(stripParenthetical(s))
    }
    
    private func baseNormalize(_ s: String) -> String {
        var r = s.folding(options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive], locale: .current)
        if let idx = r.firstIndex(where: { [":", "–", "—", "-", "—"].contains(String($0)) }) {
            let left = r[..<idx]
            if left.count >= 4 { r = String(left) }
        }
        r = r.replacingOccurrences(of: #"[\p{P}\p{S}]"#, with: "", options: .regularExpression)
        r = r.replacingOccurrences(of: #"\s+"#, with: "", options: .regularExpression)
        return r.lowercased()
    }
    
    private func stripParenthetical(_ s: String) -> String {
        return s.replacingOccurrences(of: #"\s*[\(\[\{][^\)\]\}]*[\)\]\}]"#, with: "", options: .regularExpression)
    }
    
    private func stripQualifiers(_ s: String) -> String {
        let pattern = #"(?i)\s*-\s*(live|remaster(ed)?|acoustic|inst(rumental)?|mr|ver\.?|version|original|clean|explicit|edit|mix|ost).*$"#
        return s.replacingOccurrences(of: pattern, with: "", options: .regularExpression)
    }
    
    private func levenshtein(_ a: String, _ b: String) -> Int {
        let aChars = Array(a), bChars = Array(b)
        if aChars.isEmpty { return bChars.count }
        if bChars.isEmpty { return aChars.count }
        var dist = Array(repeating: Array(repeating: 0, count: bChars.count + 1), count: aChars.count + 1)
        for i in 0...aChars.count { dist[i][0] = i }
        for j in 0...bChars.count { dist[0][j] = j }
        for i in 1...aChars.count {
            for j in 1...bChars.count {
                let cost = (aChars[i-1] == bChars[j-1]) ? 0 : 1
                dist[i][j] = min(dist[i-1][j] + 1, dist[i][j-1] + 1, dist[i-1][j-1] + cost)
            }
        }
        return dist[aChars.count][bChars.count]
    }
    
    private func similarity(_ a: String, _ b: String) -> Double {
        if a.isEmpty && b.isEmpty { return 1.0 }
        let d = Double(levenshtein(a, b))
        let m = Double(max(a.count, b.count))
        return max(0.0, 1.0 - d / m)
    }
    
    private func areArtistsEquivalent(_ a: String, _ b: String) -> Bool {
        let na = normalizeArtist(a)
        let nb = normalizeArtist(b)
        if na == nb { return true }
        
        let canonicalA = artistCanonicals[na] ?? na
        let canonicalB = artistCanonicals[nb] ?? nb
        
        return canonicalA == canonicalB
    }
    
    private func findBestMatch(songs: [TJMediaSong], originalTitle: String, originalArtist: String) -> TJMediaSong? {
        let nt = normalizeTitle(originalTitle)
        let na = normalizeArtist(originalArtist)
        
        let exactTitleMatches = songs.filter { normalizeTitle($0.title) == nt }
        if !exactTitleMatches.isEmpty {
            if let aliasHit = exactTitleMatches.first(where: { areArtistsEquivalent($0.artist, originalArtist) }) {
                return aliasHit
            }
            return exactTitleMatches.max {
                similarity(normalizeArtist($0.artist), na) < similarity(normalizeArtist($1.artist), na)
            }
        }
        
        struct Scored { let song: TJMediaSong; let score: Double }
        var scored: [Scored] = []
        
        for s in songs {
            let st = normalizeTitle(s.title)
            let sa = normalizeArtist(s.artist)
            
            let titleScore = similarity(st, nt)
            if titleScore < 0.65 { continue }
            
            let isAlias = areArtistsEquivalent(sa, na)
            let artistScore: Double = isAlias ? 1.0 : similarity(sa, na)
            let bonus = isAlias ? 0.08 : 0.0
            
            let finalScore = 0.75 * titleScore + 0.25 * artistScore + bonus
            scored.append(Scored(song: s, score: finalScore))
        }
        
        return scored.max(by: { $0.score < $1.score })?.song
    }
}
