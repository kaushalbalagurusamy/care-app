import Foundation
import SwiftUI

// MARK: - Clinical Safety Risk Tiers (Matching Figma Screen 9)
public enum SafetyTier: String, CaseIterable, Codable, Hashable {
    case healthy = "Safe"
    case moderate = "Moderate Risk"
    case highRisk = "High Risk"
    
    public var scoreCutoffLabel: String {
        switch self {
        case .healthy: return "75 or above"
        case .moderate: return "60 to 75"
        case .highRisk: return "Less than 60"
        }
    }
    
    public var clinicalExplanation: String {
        switch self {
        case .healthy:
            return "This score indicates a sturdy, supportive connection. It is a safe space for trying out new relational skills and discussing concrete ways to support one another."
        case .moderate:
            return "This score suggests moderate safety with room for improvement. While not the first place to turn for vulnerability, you can practice skills here as you gain confidence, and eventually invite the other person to work on deepening your connection."
        case .highRisk:
            return "This score indicates significant relational problems that cannot tolerate much vulnerability or conflict. Do not attempt new skills here. If the relationship is frankly abusive, please immediately seek help from a professional (like a counselor, physician, or domestic violence specialist) to explore extrication."
        }
    }
    
    public var tierColor: Color {
        switch self {
        case .healthy: return Theme.Colors.Safety.lowRisk
        case .moderate: return Theme.Colors.Safety.moderateRisk
        case .highRisk: return Theme.Colors.Safety.highRisk
        }
    }
    
    public var backgroundColor: Color {
        switch self {
        case .healthy: return Theme.Colors.Safety.lowRiskBackground
        case .moderate: return Theme.Colors.Safety.moderateRiskBackground
        case .highRisk: return Theme.Colors.Safety.highRiskBackground
        }
    }
}

// MARK: - Domain Score Breakdown (Earned / Max Points)
public struct DomainScoreBreakdown: Hashable, Codable {
    public let domain: CAREDomain
    public let earnedPoints: Double
    public let maxPossiblePoints: Double
    public var vagalToneStatus: String?
    
    public var percentage: Double {
        guard maxPossiblePoints > 0 else { return 0.0 }
        return earnedPoints / maxPossiblePoints
    }
    
    public init(
        domain: CAREDomain,
        earnedPoints: Double,
        maxPossiblePoints: Double = 125.0,
        vagalToneStatus: String? = nil
    ) {
        self.domain = domain
        self.earnedPoints = earnedPoints
        self.maxPossiblePoints = maxPossiblePoints
        self.vagalToneStatus = vagalToneStatus
    }
}

// MARK: - Relational Safety Distribution
public struct RelationalSafetyDistribution: Hashable, Codable {
    public let safePercentage: Double       // e.g. 0.21 (21%)
    public let moderatePercentage: Double   // e.g. 0.39 (39%)
    public let highRiskPercentage: Double   // e.g. 0.40 (40%)
    
    public init(safePercentage: Double, moderatePercentage: Double, highRiskPercentage: Double) {
        self.safePercentage = safePercentage
        self.moderatePercentage = moderatePercentage
        self.highRiskPercentage = highRiskPercentage
    }
}

// MARK: - Individual Result Card Data (For Swipeable Carousel on Screen 8)
public struct IndividualResult: Identifiable, Hashable, Codable {
    public let participant: AssessmentParticipant
    public let normalizedScore: Double      // 0 - 100
    public let safetyTier: SafetyTier
    public let domainBreakdown: [CAREDomain: Double]
    
    public var id: UUID { participant.id }
    
    public init(
        participant: AssessmentParticipant,
        normalizedScore: Double,
        safetyTier: SafetyTier,
        domainBreakdown: [CAREDomain: Double]
    ) {
        self.participant = participant
        self.normalizedScore = normalizedScore
        self.safetyTier = safetyTier
        self.domainBreakdown = domainBreakdown
    }
}

// MARK: - Comprehensive Assessment Result Entity
public struct AssessmentResult: Identifiable, Hashable, Codable {
    public let id: UUID
    public let domainScores: [CAREDomain: DomainScoreBreakdown]
    public let safetyDistribution: RelationalSafetyDistribution
    public let individualResults: [IndividualResult]
    public let timestamp: Date
    
    public init(
        id: UUID = UUID(),
        domainScores: [CAREDomain: DomainScoreBreakdown],
        safetyDistribution: RelationalSafetyDistribution,
        individualResults: [IndividualResult],
        timestamp: Date = Date()
    ) {
        self.id = id
        self.domainScores = domainScores
        self.safetyDistribution = safetyDistribution
        self.individualResults = individualResults
        self.timestamp = timestamp
    }
}

// MARK: - Mock Initial Result (Matching Figma Screen 8)
public extension AssessmentResult {
    static let figmaMockResult: AssessmentResult = {
        let person = Person(name: "Sarah Mitchell", initials: "SM", category: .partner, age: 32)
        let participant = AssessmentParticipant(person: person, percentTimeSpent: 0.30)
        let individual = IndividualResult(
            participant: participant,
            normalizedScore: 80.0,
            safetyTier: .healthy,
            domainBreakdown: [.calm: 18, .accepted: 20, .resonant: 15, .energetic: 22]
        )
        
        let domains: [CAREDomain: DomainScoreBreakdown] = [
            .calm: DomainScoreBreakdown(domain: .calm, earnedPoints: 18, maxPossiblePoints: 125, vagalToneStatus: "Good Vagal Tone"),
            .accepted: DomainScoreBreakdown(domain: .accepted, earnedPoints: 20, maxPossiblePoints: 125),
            .resonant: DomainScoreBreakdown(domain: .resonant, earnedPoints: 15, maxPossiblePoints: 125),
            .energetic: DomainScoreBreakdown(domain: .energetic, earnedPoints: 22, maxPossiblePoints: 125)
        ]
        
        return AssessmentResult(
            domainScores: domains,
            safetyDistribution: RelationalSafetyDistribution(safePercentage: 0.21, moderatePercentage: 0.39, highRiskPercentage: 0.40),
            individualResults: [individual]
        )
    }()
}
