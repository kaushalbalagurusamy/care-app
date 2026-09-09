import Testing
import Foundation
@testable import CAREApp

@Suite("FuzzyMatcher Search & Typo-Tolerance Test Suite")
struct FuzzyMatcherTests {

    let candidates = [
        "Sarah Mitchell",
        "James Rivera",
        "Emily Chen",
        "David Thompson",
        "Anya Patel"
    ]

    @Test("TEST-FUZ-01: Exact and lowercase substring matching")
    func testExactAndSubstringMatching() {
        #expect(FuzzyMatcher.matches(query: "Sarah", target: "Sarah Mitchell"))
        #expect(FuzzyMatcher.matches(query: "sarah", target: "Sarah Mitchell"))
        #expect(FuzzyMatcher.matches(query: "mitchell", target: "Sarah Mitchell"))
        #expect(FuzzyMatcher.matches(query: "mitch", target: "Sarah Mitchell"))
        #expect(FuzzyMatcher.matches(query: "chen", target: "Emily Chen"))
    }

    @Test("TEST-FUZ-02: Typo tolerance and edit distance (Levenshtein <= 2)")
    func testTypoTolerance() {
        // "sara" (missing h) matches "Sarah Mitchell"
        #expect(FuzzyMatcher.matches(query: "sara", target: "Sarah Mitchell"))
        // "emly" (missing i) matches "Emily Chen"
        #expect(FuzzyMatcher.matches(query: "emly", target: "Emily Chen"))
        // "jams" (missing e) matches "James Rivera"
        #expect(FuzzyMatcher.matches(query: "jams", target: "James Rivera"))
        // "thomson" (missing p) matches "David Thompson"
        #expect(FuzzyMatcher.matches(query: "thomson", target: "David Thompson"))
        // "ania" (y -> i) matches "Anya Patel"
        #expect(FuzzyMatcher.matches(query: "ania", target: "Anya Patel"))
    }

    @Test("TEST-FUZ-03: Whitespace resilience and normalization")
    func testWhitespaceResilience() {
        #expect(FuzzyMatcher.matches(query: "   sarah   ", target: "Sarah Mitchell"))
        #expect(FuzzyMatcher.matches(query: "sarahmitchell", target: "Sarah Mitchell"))
        #expect(FuzzyMatcher.matches(query: "emilychen", target: "Emily Chen"))
    }

    @Test("TEST-FUZ-04: Non-matching strings return false")
    func testNonMatchingStrings() {
        #expect(!FuzzyMatcher.matches(query: "xyz123", target: "Sarah Mitchell"))
        #expect(!FuzzyMatcher.matches(query: "robert", target: "Sarah Mitchell"))
        #expect(!FuzzyMatcher.matches(query: "alexander", target: "Emily Chen"))
    }

    @Test("TEST-FUZ-05: Filtering and ranking candidate lists")
    func testFilteringAndRanking() {
        let results = FuzzyMatcher.filterStrings(query: "emly", candidates: candidates)
        #expect(!results.isEmpty)
        #expect(results.first == "Emily Chen")

        let emptyResults = FuzzyMatcher.filterStrings(query: "", candidates: candidates)
        #expect(emptyResults.count == candidates.count)
    }
}
