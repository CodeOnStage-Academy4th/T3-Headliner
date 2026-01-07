import Foundation

final class KaraokeMatcher {
    
    static let shared = KaraokeMatcher()
    
    private init() {}
    
    func findBestMatch(songs: [KaraokeSong], originalTitle: String, originalArtist: String) -> KaraokeSong? {
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
        
        struct Scored { let song: KaraokeSong; let score: Double }
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
    
    func stripQualifiers(_ s: String) -> String {
        let pattern = #"(?i)\s*-\s*(live|remaster(ed)?|acoustic|inst(rumental)?|mr|ver\.?|version|original|clean|explicit|edit|mix|ost).*$"#
        return s.replacingOccurrences(of: pattern, with: "", options: .regularExpression)
    }
    
    func stripParenthetical(_ s: String) -> String {
        return s.replacingOccurrences(of: #"\s*[\(\[\{][^\)\]\}]*[\)\]\}]"#, with: "", options: .regularExpression)
    }
    
    // MARK: - Private Helpers
    
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
        let normalized = stripQualifiers(stripParenthetical(s))
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: #",\s*[^,]*$"#, with: "", options: .regularExpression)
        
        return baseNormalize(normalized)
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
}
