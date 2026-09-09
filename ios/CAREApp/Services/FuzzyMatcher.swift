import Foundation

// MARK: - Fuzzy String Matching Utility
/// High-performance, zero-dependency fuzzy string matching engine.
/// Supports exact substring match, token containment, subsequence matching,
/// and Damerau-Levenshtein distance for typo tolerance (distance <= 2).
public enum FuzzyMatcher {
    
    /// Returns a normalized similarity score between 0.0 (no match) and 1.0 (exact match).
    public static func score(query: String, target: String) -> Double {
        let q = normalize(query)
        let t = normalize(target)
        
        guard !q.isEmpty else { return 1.0 }
        guard !t.isEmpty else { return 0.0 }
        
        // 1. Exact match
        if q == t { return 1.0 }
        
        // 2. Target contains full query
        if t.contains(q) {
            let lengthRatio = Double(q.count) / Double(t.count)
            return 0.85 + (0.15 * lengthRatio)
        }
        
        // 3. Word token matching (e.g. query "mitchell" against "sarah mitchell")
        let targetWords = t.components(separatedBy: " ").filter { !$0.isEmpty }
        let queryWords = q.components(separatedBy: " ").filter { !$0.isEmpty }
        
        var wordScores: [Double] = []
        for qWord in queryWords {
            var bestWordScore = 0.0
            for tWord in targetWords {
                if tWord == qWord {
                    bestWordScore = max(bestWordScore, 1.0)
                } else if tWord.hasPrefix(qWord) {
                    bestWordScore = max(bestWordScore, 0.90)
                } else if tWord.contains(qWord) {
                    bestWordScore = max(bestWordScore, 0.80)
                } else {
                    let dist = levenshteinDistance(qWord, tWord)
                    let maxLen = max(qWord.count, tWord.count)
                    if dist <= 2 && maxLen > 2 {
                        let sim = 1.0 - (Double(dist) / Double(maxLen))
                        bestWordScore = max(bestWordScore, sim * 0.88)
                    }
                }
            }
            wordScores.append(bestWordScore)
        }
        
        if !wordScores.isEmpty {
            let avgWordScore = wordScores.reduce(0.0, +) / Double(wordScores.count)
            if avgWordScore >= 0.50 {
                return avgWordScore
            }
        }
        
        // 4. Whole string Levenshtein distance
        let totalDist = levenshteinDistance(q, t)
        if totalDist <= 2 {
            let maxLen = max(q.count, t.count)
            return max(0.65, 1.0 - (Double(totalDist) / Double(maxLen)))
        }
        
        // 5. Subsequence alignment (letters appear in order, e.g. "srh" in "sarah")
        if isSubsequence(q, in: t) {
            return 0.60
        }
        
        return 0.0
    }
    
    /// Determines whether the target matches the query based on a similarity threshold.
    public static func matches(query: String, target: String, threshold: Double = 0.55) -> Bool {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return true }
        return score(query: trimmed, target: target) >= threshold
    }
    
    /// Filters and ranks a list of items using fuzzy matching against a string property.
    public static func filter<T>(
        query: String,
        items: [T],
        keyPath: KeyPath<T, String>,
        threshold: Double = 0.55
    ) -> [T] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return items }
        
        let scored = items.compactMap { item -> (T, Double)? in
            let text = item[keyPath: keyPath]
            let s = score(query: trimmed, target: text)
            guard s >= threshold else { return nil }
            return (item, s)
        }
        
        return scored.sorted { $0.1 > $1.1 }.map { $0.0 }
    }
    
    /// Filters and ranks a list of strings directly.
    public static func filterStrings(
        query: String,
        candidates: [String],
        threshold: Double = 0.55
    ) -> [String] {
        return filter(query: query, items: candidates, keyPath: \.self, threshold: threshold)
    }
    
    /// Calculates Damerau-Levenshtein edit distance (insertions, deletions, substitutions, transpositions).
    public static func levenshteinDistance(_ s1: String, _ s2: String) -> Int {
        let a = Array(s1)
        let b = Array(s2)
        let m = a.count
        let n = b.count
        
        if m == 0 { return n }
        if n == 0 { return m }
        
        var d = Array(repeating: Array(repeating: 0, count: n + 1), count: m + 1)
        
        for i in 0...m { d[i][0] = i }
        for j in 0...n { d[0][j] = j }
        
        for i in 1...m {
            for j in 1...n {
                let cost = (a[i - 1] == b[j - 1]) ? 0 : 1
                d[i][j] = min(
                    d[i - 1][j] + 1,        // deletion
                    d[i][j - 1] + 1,        // insertion
                    d[i - 1][j - 1] + cost   // substitution
                )
                
                // Transposition
                if i > 1 && j > 1 && a[i - 1] == b[j - 2] && a[i - 2] == b[j - 1] {
                    d[i][j] = min(d[i][j], d[i - 2][j - 2] + 1)
                }
            }
        }
        
        return d[m][n]
    }
    
    /// Checks if characters of subsequence appear in target in identical order.
    private static func isSubsequence(_ sub: String, in target: String) -> Bool {
        var subIdx = sub.startIndex
        var targetIdx = target.startIndex
        
        while subIdx < sub.endIndex && targetIdx < target.endIndex {
            if sub[subIdx] == target[targetIdx] {
                subIdx = sub.index(after: subIdx)
            }
            targetIdx = target.index(after: targetIdx)
        }
        
        return subIdx == sub.endIndex
    }
    
    /// Strips punctuation, collapses extra spaces, and lowercases.
    public static func normalize(_ str: String) -> String {
        return str
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
