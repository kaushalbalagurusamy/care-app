import SwiftUI

// MARK: - Screen 9: Relational Risk Groups Deep Dive (Figma Frame 58:3)
public struct SurveyResultsExpandedView: View {
    public let router: AppRouter
    
    public init(router: AppRouter) {
        self.router = router
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Standardized Header Bar with Modular AppIcons
            HeaderNavBar(showBackButton: true, onBack: { router.pop() })
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Relational Risk Groups")
                            .font(Theme.Typography.poppins(.bold, size: 28))
                            .foregroundColor(Theme.Colors.textPrimary)
                        Text("Understand how each relationship score reflects the safety and growth potential of your connections.")
                            .font(Theme.Typography.poppins(.regular, size: 13))
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                    .padding(.top, Theme.Spacing.headerTitleSpacing)
                    
                    // MARK: 3 Relational Risk Tier Cards (Figma Frame 58:3)
                    VStack(spacing: 12) {
                        
                        // 1. Safe Tier
                        RelationalRiskTierCard(
                            badgeTitle: "Safe",
                            badgeColor: ResultsV2Palette.safe,
                            scoreRange: "75 or above",
                            groupTitle: "High Safety Group",
                            explanation: "This score indicates a sturdy, supportive connection. It is a safe space for trying out new relational skills and discussing concrete ways to support one another."
                        )
                        
                        // 2. Moderate Risk Tier
                        RelationalRiskTierCard(
                            badgeTitle: "Moderate Risk",
                            badgeColor: ResultsV2Palette.moderate,
                            scoreRange: "60 to 74",
                            groupTitle: "Moderate Safety Group",
                            explanation: "This score suggests moderate safety with room for improvement. While not the first place to turn for vulnerability, you can practice skills here as you gain confidence, and eventually invite the other person to work on deepening your connection."
                        )
                        
                        // 3. High Risk Tier
                        RelationalRiskTierCard(
                            badgeTitle: "High Risk",
                            badgeColor: ResultsV2Palette.highRisk,
                            scoreRange: "Less than 60",
                            groupTitle: "High Risk Safety Group",
                            explanation: "This score indicates significant relational problems that cannot tolerate much vulnerability or conflict. Do not attempt new skills here. If the relationship is frankly abusive, please immediately seek help from a professional (like a counselor, physician, or domestic violence specialist) to explore extrication."
                        )
                    }
                    
                    // MARK: Bottom Action Button (Figma Frame 58:3)
                    SecondaryButton(
                        title: "Back to Results",
                        icon: "arrow.left",
                        action: {
                            router.pop()
                        }
                    )
                    .accessibilityIdentifier("BackToResultsButton")
                    .padding(.top, 6)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
        }
        .background(Color(hex: "#F8FAFC"))
    }
}

// MARK: - Relational Risk Tier Card (Figma Frame 58:3)
public struct RelationalRiskTierCard: View {
    public let badgeTitle: String
    public let badgeColor: Color
    public let scoreRange: String
    public let groupTitle: String
    public let explanation: String
    
    public init(
        badgeTitle: String,
        badgeColor: Color,
        scoreRange: String,
        groupTitle: String,
        explanation: String
    ) {
        self.badgeTitle = badgeTitle
        self.badgeColor = badgeColor
        self.scoreRange = scoreRange
        self.groupTitle = groupTitle
        self.explanation = explanation
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Badge & Score Range Header
            HStack(spacing: 12) {
                Text(badgeTitle)
                    .font(Theme.Typography.poppins(.bold, size: 13))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 5)
                    .background(badgeColor)
                    .clipShape(Capsule())
                
                Text(scoreRange)
                    .font(Theme.Typography.poppins(.bold, size: 15.5))
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Spacer()
            }
            
            Text(groupTitle)
                .font(Theme.Typography.poppins(.bold, size: 16))
                .foregroundColor(Theme.Colors.textPrimary)

            // Explanation Body
            Text(explanation)
                .font(Theme.Typography.poppins(.regular, size: 13.5))
                .foregroundColor(Theme.Colors.textSecondary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Theme.Colors.dividerSubtle, lineWidth: 1)
        )
    }
}

// MARK: - Previews
#Preview("Survey Results Expanded View") {
    SurveyResultsExpandedView(router: AppRouter())
}
