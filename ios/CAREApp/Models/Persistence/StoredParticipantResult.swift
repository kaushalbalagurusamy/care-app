import Foundation
import SwiftData

// MARK: - SwiftData CloudKit-Compliant Persistent Participant Result
@Model
public final class StoredParticipantResult {
    public var id: UUID = UUID()
    public var personName: String = ""
    public var initials: String = ""
    public var categoryRaw: String = "Partner"
    public var customCategoryName: String? = nil
    public var age: Int = 30
    public var percentTimeSpent: Double = 0.20
    public var individualScore: Double = 0.0
    public var safetyTierRaw: String = "Safe"
    public var calmScore: Double = 0.0
    public var acceptedScore: Double = 0.0
    public var resonantScore: Double = 0.0
    public var energeticScore: Double = 0.0
    
    public init(
        id: UUID = UUID(),
        personName: String = "",
        initials: String = "",
        categoryRaw: String = "Partner",
        customCategoryName: String? = nil,
        age: Int = 30,
        percentTimeSpent: Double = 0.20,
        individualScore: Double = 0.0,
        safetyTierRaw: String = "Safe",
        calmScore: Double = 0.0,
        acceptedScore: Double = 0.0,
        resonantScore: Double = 0.0,
        energeticScore: Double = 0.0
    ) {
        self.id = id
        self.personName = personName
        self.initials = initials
        self.categoryRaw = categoryRaw
        self.customCategoryName = customCategoryName
        self.age = age
        self.percentTimeSpent = percentTimeSpent
        self.individualScore = individualScore
        self.safetyTierRaw = safetyTierRaw
        self.calmScore = calmScore
        self.acceptedScore = acceptedScore
        self.resonantScore = resonantScore
        self.energeticScore = energeticScore
    }
    
    public convenience init(from result: IndividualResult) {
        self.init(
            id: result.id,
            personName: result.participant.person.name,
            initials: result.participant.person.initials,
            categoryRaw: result.participant.person.category.rawValue,
            customCategoryName: result.participant.person.customCategoryName,
            age: result.participant.person.age,
            percentTimeSpent: result.participant.percentTimeSpent,
            individualScore: result.normalizedScore,
            safetyTierRaw: result.safetyTier.rawValue,
            calmScore: result.domainBreakdown[.calm] ?? 0.0,
            acceptedScore: result.domainBreakdown[.accepted] ?? 0.0,
            resonantScore: result.domainBreakdown[.resonant] ?? 0.0,
            energeticScore: result.domainBreakdown[.energetic] ?? 0.0
        )
    }
    
    public func toDomain() -> IndividualResult {
        let category = RelationshipCategory(rawValue: categoryRaw) ?? .partner
        let person = Person(
            id: id,
            name: personName,
            initials: initials,
            category: category,
            customCategoryName: customCategoryName,
            age: age
        )
        let participant = AssessmentParticipant(person: person, percentTimeSpent: percentTimeSpent)
        let tier: SafetyTier = {
            switch safetyTierRaw {
            case "Safe", "healthy": return .healthy
            case "Moderate Risk", "moderate": return .moderate
            default: return .highRisk
            }
        }()
        let breakdown: [CAREDomain: Double] = [
            .calm: calmScore,
            .accepted: acceptedScore,
            .resonant: resonantScore,
            .energetic: energeticScore
        ]
        return IndividualResult(
            participant: participant,
            normalizedScore: individualScore,
            safetyTier: tier,
            domainBreakdown: breakdown
        )
    }
}
