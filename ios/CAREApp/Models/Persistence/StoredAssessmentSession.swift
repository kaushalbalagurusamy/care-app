import Foundation
import SwiftData

// MARK: - SwiftData CloudKit-Compliant Persistent Assessment Session Model
@Model
public final class StoredAssessmentSession {
    public var id: UUID = UUID()
    public var date: Date = Date()
    public var totalScore: Double = 0.0
    public var overallTierRaw: String = "healthy"
    public var safePercentage: Double = 0.0
    public var moderatePercentage: Double = 0.0
    public var highRiskPercentage: Double = 0.0
    public var calmScore: Double = 0.0
    public var acceptedScore: Double = 0.0
    public var resonantScore: Double = 0.0
    public var energeticScore: Double = 0.0
    // Existing records predate this field and remain on the original /100 scale.
    public var categoryMaxPoints: Double = 100.0
    public var scoringVersion: Int = 1
    
    @Relationship(deleteRule: .cascade)
    public var participants: [StoredParticipantResult]? = []
    
    public init(
        id: UUID = UUID(),
        date: Date = Date(),
        totalScore: Double = 0.0,
        overallTierRaw: String = "healthy",
        safePercentage: Double = 0.0,
        moderatePercentage: Double = 0.0,
        highRiskPercentage: Double = 0.0,
        calmScore: Double = 0.0,
        acceptedScore: Double = 0.0,
        resonantScore: Double = 0.0,
        energeticScore: Double = 0.0,
        categoryMaxPoints: Double = 100.0,
        scoringVersion: Int = 1,
        participants: [StoredParticipantResult] = []
    ) {
        self.id = id
        self.date = date
        self.totalScore = totalScore
        self.overallTierRaw = overallTierRaw
        self.safePercentage = safePercentage
        self.moderatePercentage = moderatePercentage
        self.highRiskPercentage = highRiskPercentage
        self.calmScore = calmScore
        self.acceptedScore = acceptedScore
        self.resonantScore = resonantScore
        self.energeticScore = energeticScore
        self.categoryMaxPoints = categoryMaxPoints
        self.scoringVersion = scoringVersion
        self.participants = participants
    }
    
    public convenience init(from result: AssessmentResult) {
        let storedParticipants = result.individualResults.map { StoredParticipantResult(from: $0) }
        let calm = result.domainScores[.calm]?.earnedPoints ?? 0.0
        let accepted = result.domainScores[.accepted]?.earnedPoints ?? 0.0
        let resonant = result.domainScores[.resonant]?.earnedPoints ?? 0.0
        let energetic = result.domainScores[.energetic]?.earnedPoints ?? 0.0
        
        self.init(
            id: result.id,
            date: result.timestamp,
            totalScore: calm + accepted + resonant + energetic,
            overallTierRaw: "healthy",
            safePercentage: result.safetyDistribution.safePercentage,
            moderatePercentage: result.safetyDistribution.moderatePercentage,
            highRiskPercentage: result.safetyDistribution.highRiskPercentage,
            calmScore: calm,
            acceptedScore: accepted,
            resonantScore: resonant,
            energeticScore: energetic,
            categoryMaxPoints: result.domainScores[.calm]?.maxPossiblePoints ?? 125.0,
            scoringVersion: 2,
            participants: storedParticipants
        )
    }
    
    public func toDomain() -> AssessmentResult {
        let mappedParticipants = (participants ?? []).map { $0.toDomain() }
        let domainScores: [CAREDomain: DomainScoreBreakdown] = [
            .calm: DomainScoreBreakdown(domain: .calm, earnedPoints: calmScore, maxPossiblePoints: categoryMaxPoints),
            .accepted: DomainScoreBreakdown(domain: .accepted, earnedPoints: acceptedScore, maxPossiblePoints: categoryMaxPoints),
            .resonant: DomainScoreBreakdown(domain: .resonant, earnedPoints: resonantScore, maxPossiblePoints: categoryMaxPoints),
            .energetic: DomainScoreBreakdown(domain: .energetic, earnedPoints: energeticScore, maxPossiblePoints: categoryMaxPoints)
        ]
        let safetyDist = RelationalSafetyDistribution(
            safePercentage: safePercentage,
            moderatePercentage: moderatePercentage,
            highRiskPercentage: highRiskPercentage
        )
        return AssessmentResult(
            id: id,
            domainScores: domainScores,
            safetyDistribution: safetyDist,
            individualResults: mappedParticipants,
            timestamp: date
        )
    }
}
