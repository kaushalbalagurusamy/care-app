import Testing
import SwiftUI
@testable import CAREApp

@Suite("V2 Survey Results & Trends Views Test Suite")
struct V2ResultsAndTrendsTests {
    
    @Test("SurveyResultsV2View instantiates with default design configuration")
    @MainActor
    func testSurveyResultsV2Instantiation() {
        let view = SurveyResultsV2View(result: .figmaMockResult)
        #expect(view != nil)
    }
    
    @Test("PastResultsV2View instantiates with default design configuration")
    @MainActor
    func testPastResultsV2Instantiation() {
        let view = PastResultsV2View()
        #expect(view != nil)
    }

    @Test("Donut slices follow the relative category scores, including saved 125-point results")
    func testScoreCompositionProportions() {
        let result = AssessmentResult(
            domainScores: [
                .calm: DomainScoreBreakdown(domain: .calm, earnedPoints: 125, maxPossiblePoints: 125),
                .accepted: DomainScoreBreakdown(domain: .accepted, earnedPoints: 62.5, maxPossiblePoints: 125),
                .resonant: DomainScoreBreakdown(domain: .resonant, earnedPoints: 31.25, maxPossiblePoints: 125),
                .energetic: DomainScoreBreakdown(domain: .energetic, earnedPoints: 31.25, maxPossiblePoints: 125)
            ],
            safetyDistribution: RelationalSafetyDistribution(safePercentage: 0.5, moderatePercentage: 0.3, highRiskPercentage: 0.2),
            individualResults: []
        )

        let segments = ResultsV2Metrics.compositionSegments(result)
        #expect(segments.count == 4)
        #expect(abs(segments[0].percentage - 0.5) < 0.001)
        #expect(abs(segments[1].percentage - 0.25) < 0.001)
        #expect(abs(segments[2].percentage - 0.125) < 0.001)
        #expect(abs(segments[3].percentage - 0.125) < 0.001)
        #expect(ResultsV2CategoryCopy.tierTitle(for: .calm, score: 76) == "Good Vagal Tone")
        #expect(ResultsV2CategoryCopy.tierTitle(for: .calm, score: 75) == "Moderate Vagal Tone")
    }

    @Test("Trend point identity stays tied to its saved assessment even when dates match")
    func testHistoricalTrendPointIdentity() {
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let first = AssessmentResult(domainScores: [:], safetyDistribution: .init(safePercentage: 1, moderatePercentage: 0, highRiskPercentage: 0), individualResults: [], timestamp: date)
        let second = AssessmentResult(domainScores: [:], safetyDistribution: .init(safePercentage: 0, moderatePercentage: 1, highRiskPercentage: 0), individualResults: [], timestamp: date)
        let points = ResultsV2TrendPoint.from([first, second])
        #expect(points.map(\.resultID) == [first.id, second.id])
        #expect(points[0].resultID != points[1].resultID)
    }

    @Test("W11: every historical chart point has room for a separate 44-point touch target")
    func testHistoricalTrendPointSpacing() {
        let pointCount = 51
        let plotWidth = ResultsV2TrendChart.requiredInteractiveWidth(pointCount: pointCount) - 32
        #expect(plotWidth / CGFloat(pointCount - 1) >= 44)
    }
}
