import Foundation

// MARK: - Pluggable Scoring Configuration
public struct ScoringConfiguration {
    public var safeScoreCutoff: Double
    public var moderateScoreCutoff: Double
    public var domainMaxPoints: Double
    
    public init(
        safeScoreCutoff: Double = 75.0,
        moderateScoreCutoff: Double = 60.0,
        domainMaxPoints: Double = 125.0
    ) {
        self.safeScoreCutoff = safeScoreCutoff
        self.moderateScoreCutoff = moderateScoreCutoff
        self.domainMaxPoints = domainMaxPoints
    }
}

// MARK: - Scoring Engine Protocol Interface
public protocol ScoringEngineProtocol {
    func computeResult(
        participants: [AssessmentParticipant],
        recordedAnswers: [UUID: [String: SurveyOption]],
        questions: [SurveyQuestion],
        config: ScoringConfiguration
    ) -> AssessmentResult
}

// MARK: - Flexible Multi-Domain Scoring Engine Implementation
public struct FlexibleScoringEngine: ScoringEngineProtocol {
    public init() {}
    
    public func computeResult(
        participants: [AssessmentParticipant],
        recordedAnswers: [UUID: [String: SurveyOption]],
        questions: [SurveyQuestion],
        config: ScoringConfiguration = ScoringConfiguration()
    ) -> AssessmentResult {
        var individualResults: [IndividualResult] = []
        var domainEarnedTotals: [CAREDomain: Double] = [.calm: 0, .accepted: 0, .resonant: 0, .energetic: 0]
        
        var totalSafeWeight: Double = 0.0
        var totalModerateWeight: Double = 0.0
        var totalHighRiskWeight: Double = 0.0
        
        let questionMap = Dictionary(uniqueKeysWithValues: questions.map { ($0.id, $0) })
        
        for participant in participants {
            let participantAnswers = recordedAnswers[participant.id] ?? [:]
            var participantDomainSums: [CAREDomain: Double] = [.calm: 0, .accepted: 0, .resonant: 0, .energetic: 0]
            var participantTotalScore: Double = 0.0
            var answeredCount: Double = 0.0
            
            for (qId, option) in participantAnswers {
                let rawValue = option.rawScoreValue
                let question = questionMap[qId]
                let targetDomains = question?.targetDomains ?? [DomainWeightMapping(domain: .calm, weightMultiplier: 1.0)]
                
                for mapping in targetDomains {
                    let weightedPoints = rawValue * mapping.weightMultiplier * 25.0 // Scaled points
                    participantDomainSums[mapping.domain, default: 0.0] += weightedPoints
                    domainEarnedTotals[mapping.domain, default: 0.0] += weightedPoints
                }
                
                participantTotalScore += (rawValue * 100.0)
                answeredCount += 1.0
            }
            
            let normalizedScore: Double
            if answeredCount > 0 {
                normalizedScore = min(max(participantTotalScore / answeredCount, 0.0), 100.0)
            } else {
                normalizedScore = 50.0 // Neutral fallback
            }
            
            let tier: SafetyTier
            if normalizedScore >= config.safeScoreCutoff {
                tier = .healthy
                totalSafeWeight += participant.percentTimeSpent
            } else if normalizedScore >= config.moderateScoreCutoff {
                tier = .moderate
                totalModerateWeight += participant.percentTimeSpent
            } else {
                tier = .highRisk
                totalHighRiskWeight += participant.percentTimeSpent
            }
            
            let individual = IndividualResult(
                participant: participant,
                normalizedScore: normalizedScore,
                safetyTier: tier,
                domainBreakdown: participantDomainSums
            )
            individualResults.append(individual)
        }
        
        // Normalize distributions to sum to 1.0
        let totalWeight = totalSafeWeight + totalModerateWeight + totalHighRiskWeight
        let safePct = totalWeight > 0 ? (totalSafeWeight / totalWeight) : 0.33
        let modPct = totalWeight > 0 ? (totalModerateWeight / totalWeight) : 0.33
        let highPct = totalWeight > 0 ? (totalHighRiskWeight / totalWeight) : 0.34
        
        var domainBreakdowns: [CAREDomain: DomainScoreBreakdown] = [:]
        for domain in CAREDomain.allCases {
            let earned = domainEarnedTotals[domain] ?? 0.0
            let vagalStatus = (domain == .calm && earned >= 15.0) ? "Good Vagal Tone" : nil
            domainBreakdowns[domain] = DomainScoreBreakdown(
                domain: domain,
                earnedPoints: earned,
                maxPossiblePoints: config.domainMaxPoints,
                vagalToneStatus: vagalStatus
            )
        }
        
        return AssessmentResult(
            domainScores: domainBreakdowns,
            safetyDistribution: RelationalSafetyDistribution(
                safePercentage: safePct,
                moderatePercentage: modPct,
                highRiskPercentage: highPct
            ),
            individualResults: individualResults
        )
    }
}
