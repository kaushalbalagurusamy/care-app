import Foundation
import SwiftUI

// MARK: - C.A.R.E. Domain Categories Enum
public enum CAREDomain: String, CaseIterable, Codable, Hashable {
    case calm = "calm"
    case accepted = "accepted"
    case resonant = "resonant"
    case energetic = "energetic"
    
    public var letter: String {
        return String(rawValue.prefix(1)).uppercased()
    }
    
    public var title: String {
        return rawValue.capitalized
    }
    
    public var subtitle: String {
        switch self {
        case .calm: return "C is for Calm"
        case .accepted: return "A is for Accepted"
        case .resonant: return "R is for Resonant"
        case .energetic: return "E is for Energetic"
        }
    }
    
    public var explanation: String {
        switch self {
        case .calm:
            return "Fosters down-regulation of stress response systems, helping you develop neural pathways toward safety and emotional grounding."
        case .accepted:
            return "The neurobiological experience of feeling valued, validated, and safely connected within healthy relationship cultures."
        case .resonant:
            return "Activating mirror neurons to sense and dynamically align with another's emotional experience without losing yourself."
        case .energetic:
            return "The vitalizing emotional flow and neurochemical boost generated when you participate in growth-fostering, mutual bonds."
        }
    }
    
    public var themeColor: Color {
        switch self {
        case .calm: return Theme.Colors.Domains.calm
        case .accepted: return Theme.Colors.Domains.accepted
        case .resonant: return Theme.Colors.Domains.resonant
        case .energetic: return Theme.Colors.Domains.energetic
        }
    }
}

// MARK: - Configurable Multi-Domain Weight Mapping
public struct DomainWeightMapping: Hashable, Codable {
    public let domain: CAREDomain
    public let weightMultiplier: Double
    
    public init(domain: CAREDomain, weightMultiplier: Double = 1.0) {
        self.domain = domain
        self.weightMultiplier = weightMultiplier
    }
}

// MARK: - Survey Option
public struct SurveyOption: Identifiable, Hashable, Codable {
    public let id: String
    public let text: String
    public let rawScoreValue: Double // Normalized value 0.0 - 1.0 (e.g. 0.2, 0.4, 0.6, 0.8, 1.0)
    
    public init(id: String, text: String, rawScoreValue: Double) {
        self.id = id
        self.text = text
        self.rawScoreValue = rawScoreValue
    }
}

// MARK: - Survey Question
public struct SurveyQuestion: Identifiable, Hashable, Codable {
    public let id: String
    public let prompt: String
    public let targetDomains: [DomainWeightMapping]
    public let options: [SurveyOption]
    
    public init(
        id: String,
        prompt: String,
        targetDomains: [DomainWeightMapping],
        options: [SurveyOption]
    ) {
        self.id = id
        self.prompt = prompt
        self.targetDomains = targetDomains
        self.options = options
    }
}

// MARK: - Mock Initial Question Bank (Matching Figma Screen 7)
public extension SurveyQuestion {
    static let standard5PointLikertOptions: [SurveyOption] = [
        SurveyOption(id: "opt_1", text: "I feel constantly on edge, tense, or bracing for a negative reaction.", rawScoreValue: 0.20),
        SurveyOption(id: "opt_2", text: "I feel a lingering background anxiety or stress that is hard to shake.", rawScoreValue: 0.40),
        SurveyOption(id: "opt_3", text: "I feel neutral; my stress level doesn't go up, but I don't necessarily relax either.", rawScoreValue: 0.60),
        SurveyOption(id: "opt_4", text: "I feel noticeably more settled; my physical tension noticeably decreases.", rawScoreValue: 0.80),
        SurveyOption(id: "opt_5", text: "I feel completely grounded, relaxed, and physically safe in their presence.", rawScoreValue: 1.00)
    ]
    
    static let mockQuestionBank: [SurveyQuestion] = [
        SurveyQuestion(
            id: "q_1",
            prompt: "When you are around this person, how does your body physically respond?",
            targetDomains: [DomainWeightMapping(domain: .calm, weightMultiplier: 1.0)],
            options: standard5PointLikertOptions
        ),
        SurveyQuestion(
            id: "q_2",
            prompt: "How validated and accepted do you feel when sharing your vulnerable thoughts?",
            targetDomains: [DomainWeightMapping(domain: .accepted, weightMultiplier: 1.0)],
            options: standard5PointLikertOptions
        ),
        SurveyQuestion(
            id: "q_3",
            prompt: "How easily can you sense and connect with their emotional state without losing yourself?",
            targetDomains: [DomainWeightMapping(domain: .resonant, weightMultiplier: 1.0)],
            options: standard5PointLikertOptions
        ),
        SurveyQuestion(
            id: "q_4",
            prompt: "How energized and vitalized do you feel following interactions with this person?",
            targetDomains: [DomainWeightMapping(domain: .energetic, weightMultiplier: 1.0)],
            options: standard5PointLikertOptions
        )
    ]
}
