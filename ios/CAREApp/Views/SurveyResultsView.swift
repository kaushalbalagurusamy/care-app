import SwiftUI

// MARK: - Screen 8: Survey Results Comprehensive Dashboard (Figma Frame 29:4)
public struct SurveyResultsView: View {
    public let router: AppRouter
    public let result: AssessmentResult
    
    @State private var activeParticipantIndex: Int = 0
    
    public init(router: AppRouter, result: AssessmentResult) {
        self.router = router
        self.result = result
    }
    
    private var breakdownItems: [DomainBreakdownItem] {
        return CAREDomain.allCases.map { domain in
            let score = Int(result.domainScores[domain]?.earnedPoints ?? 18)
            let maxScore = Int(result.domainScores[domain]?.maxPossiblePoints ?? 125)
            
            let vagalTitle: String
            let vagalDesc: String
            switch domain {
            case .calm:
                vagalTitle = "Good Vagal Tone"
                vagalDesc = "Your smart vagus nerve helps calm and relax you. Your relationships help you manage the stress of day-to-day life."
            case .accepted:
                vagalTitle = "Belonging Signaling"
                vagalDesc = "Neural safety pathways activate when you feel recognized, valued, and accepted in your relationships."
            case .resonant:
                vagalTitle = "Co-Regulation Capacity"
                vagalDesc = "Dynamic emotional attunement allows physiological calming and empathy through shared connection."
            case .energetic:
                vagalTitle = "Autonomic Vitality"
                vagalDesc = "Growth-fostering relationships stimulate dopamine, oxytocin, and energized focus."
            }
            
            return DomainBreakdownItem(
                domain: domain,
                score: score,
                maxScore: maxScore,
                subtitleTitle: domain.subtitle,
                explanation: domain.explanation,
                vagalToneTitle: vagalTitle,
                vagalToneExplanation: vagalDesc
            )
        }
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header Bar (Figma Frame 29:4: Home on left, Chart + Profile on right)
            HeaderNavBar(
                showBackButton: false,
                showHomeButton: true,
                showChartButton: true,
                showProfileButton: true,
                onHome: { router.popToRoot() },
                onChart: { router.navigate(to: .pastResults) },
                onProfile: {}
            )
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Title Section
                    Text("Survey Results")
                        .font(Theme.Typography.poppins(.bold, size: 28))
                        .foregroundColor(Theme.Colors.textPrimary)
                        .padding(.top, 4)
                    
                    // MARK: 1. Score Composition & Category Breakdown Bubble (Figma Frame 29:4)
                    BubbleCardContainer(title: "Score Composition") {
                        VStack(alignment: .leading, spacing: 18) {
                            // 4-Domain Donut Chart
                            DonutChartView(
                                segments: [
                                    DonutSegment(title: "Calm", color: Theme.Colors.Domains.calm, percentage: 0.25),
                                    DonutSegment(title: "Accepted", color: Theme.Colors.Domains.accepted, percentage: 0.25),
                                    DonutSegment(title: "Resonant", color: Theme.Colors.Domains.resonant, percentage: 0.25),
                                    DonutSegment(title: "Energetic", color: Theme.Colors.Domains.energetic, percentage: 0.25)
                                ],
                                diameter: 190,
                                strokeWidth: 46,
                                gapDegrees: 7.0,
                                cornerRadius: 6.0
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.top, 4)
                            
                            // Category Breakdown Header
                            Text("Category Breakdown")
                                .font(Theme.Typography.poppins(.bold, size: 18))
                                .foregroundColor(Theme.Colors.textPrimary)
                                .padding(.top, 8)
                            
                            Divider()
                                .background(Theme.Colors.dividerSubtle)
                            
                            // Category Breakdown Accordion
                            CategoryBreakdownAccordion(items: breakdownItems)
                        }
                    }
                    
                    // MARK: 2. Relational Safety Bubble (Figma Frame 29:4)
                    BubbleCardContainer(
                        title: "Relational Safety",
                        showInfoIcon: true,
                        onInfoTap: { router.navigate(to: .surveyResultsExpanded) }
                    ) {
                        VStack(spacing: 20) {
                            // 3-Tier Donut Chart
                            DonutChartView(
                                segments: [
                                    DonutSegment(
                                        title: "Safe",
                                        color: Theme.Colors.Safety.lowRisk,
                                        percentage: result.safetyDistribution.safePercentage
                                    ),
                                    DonutSegment(
                                        title: "Medium Risk",
                                        color: Theme.Colors.Safety.moderateRisk,
                                        percentage: result.safetyDistribution.moderatePercentage
                                    ),
                                    DonutSegment(
                                        title: "High Risk",
                                        color: Theme.Colors.Safety.highRisk,
                                        percentage: result.safetyDistribution.highRiskPercentage
                                    )
                                ],
                                diameter: 190,
                                strokeWidth: 46,
                                gapDegrees: 7.0,
                                cornerRadius: 6.0
                            )
                            .frame(maxWidth: .infinity)
                            
                            // Legend Rows (Figma Frame 29:4)
                            VStack(spacing: 10) {
                                HStack {
                                    Circle().fill(Theme.Colors.Safety.lowRisk).frame(width: 10, height: 10)
                                    Text("Safe")
                                        .font(Theme.Typography.poppins(.medium, size: 15))
                                        .foregroundColor(Theme.Colors.textPrimary)
                                    Spacer()
                                    Text("\(Int(round(result.safetyDistribution.safePercentage * 100)))%")
                                        .font(Theme.Typography.poppins(.bold, size: 15))
                                        .foregroundColor(Theme.Colors.textPrimary)
                                }
                                HStack {
                                    Circle().fill(Theme.Colors.Safety.moderateRisk).frame(width: 10, height: 10)
                                    Text("Medium Risk")
                                        .font(Theme.Typography.poppins(.medium, size: 15))
                                        .foregroundColor(Theme.Colors.textPrimary)
                                    Spacer()
                                    Text("\(Int(round(result.safetyDistribution.moderatePercentage * 100)))%")
                                        .font(Theme.Typography.poppins(.bold, size: 15))
                                        .foregroundColor(Theme.Colors.textPrimary)
                                }
                                HStack {
                                    Circle().fill(Theme.Colors.Safety.highRisk).frame(width: 10, height: 10)
                                    Text("High Risk")
                                        .font(Theme.Typography.poppins(.medium, size: 15))
                                        .foregroundColor(Theme.Colors.textPrimary)
                                    Spacer()
                                    Text("\(Int(round(result.safetyDistribution.highRiskPercentage * 100)))%")
                                        .font(Theme.Typography.poppins(.bold, size: 15))
                                        .foregroundColor(Theme.Colors.textPrimary)
                                }
                            }
                            .padding(.horizontal, 8)
                        }
                    }
                    
                    // MARK: 3. Results by Individual Bubble (Figma Frame 29:4)
                    BubbleCardContainer(
                        title: "Results by Individual",
                        showInfoIcon: true,
                        onInfoTap: { router.navigate(to: .surveyResultsExpanded) }
                    ) {
                        VStack(spacing: 14) {
                            if !result.individualResults.isEmpty {
                                TabView(selection: $activeParticipantIndex) {
                                    ForEach(0..<result.individualResults.count, id: \.self) { index in
                                        IndividualResultCard(result: result.individualResults[index])
                                            .tag(index)
                                    }
                                }
                                .tabViewStyle(.page(indexDisplayMode: .never))
                                .frame(height: 88)
                                
                                PageIndicatorDots(
                                    totalCount: result.individualResults.count,
                                    currentIndex: activeParticipantIndex,
                                    onSelectIndex: { index in
                                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                            activeParticipantIndex = index
                                        }
                                    }
                                )
                                .padding(.top, 4)
                            }
                        }
                    }
                    // MARK: 4. Action Buttons
                    VStack(spacing: 12) {
                        PrimaryButton(title: "View Past Results", appIcon: .chart) {
                            router.navigate(to: .pastResults)
                        }
                        
                        SecondaryButton(title: "Return to Home", appIcon: .home) {
                            router.popToRoot()
                        }
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
        .background(Theme.Colors.background)
    }
}

// MARK: - Previews
#Preview("Survey Results View") {
    SurveyResultsView(
        router: AppRouter(),
        result: AssessmentResult.figmaMockResult
    )
}
