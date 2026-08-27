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
            HeaderNavBar(
                showBackButton: true,
                showHomeButton: true,
                showChartButton: true,
                showProfileButton: true,
                onBack: { router.pop() },
                onHome: { router.popToRoot() },
                onChart: { router.navigate(to: .pastResults) },
                onProfile: {}
            )
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    
                    // Title Header with Info Icon (Figma Frame 58:3)
                    HStack(spacing: 10) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 22, weight: .regular))
                            .foregroundColor(Theme.Colors.primary)
                        
                        Text("About Relational Risk Groups")
                            .font(Theme.Typography.poppins(.bold, size: 20))
                            .foregroundColor(Theme.Colors.textPrimary)
                    }
                    .padding(.top, 2)
                    
                    // MARK: 3 Relational Risk Tier Cards (Figma Frame 58:3)
                    VStack(spacing: 12) {
                        
                        // 1. Safe Tier
                        RelationalRiskTierCard(
                            badgeTitle: "Safe",
                            badgeColor: Theme.Colors.Safety.lowRisk,
                            scoreRange: "75 or above",
                            explanation: "This score indicates a sturdy, supportive connection. It is a safe space for trying out new relational skills and discussing concrete ways to support one another."
                        )
                        
                        // 2. Moderate Risk Tier
                        RelationalRiskTierCard(
                            badgeTitle: "Moderate Risk",
                            badgeColor: Theme.Colors.Safety.moderateRisk,
                            scoreRange: "60 to 75",
                            explanation: "This score suggests moderate safety with room for improvement. While not the first place to turn for vulnerability, you can practice skills here as you gain confidence, and eventually invite the other person to work on deepening your connection."
                        )
                        
                        // 3. High Risk Tier
                        RelationalRiskTierCard(
                            badgeTitle: "High Risk",
                            badgeColor: Theme.Colors.Safety.highRisk,
                            scoreRange: "Less than 60",
                            explanation: "This score indicates significant relational problems that cannot tolerate much vulnerability or conflict. Do not attempt new skills here. If the relationship is frankly abusive, please immediately seek help from a professional (like a counselor, physician, or domestic violence specialist) to explore extrication."
                        )
                    }
                    
                    // MARK: Bottom Action Button (Figma Frame 58:3)
                    PrimaryButton(title: "Back to Results") {
                        router.pop()
                    }
                    .padding(.top, 6)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
        }
        .background(Theme.Colors.background)
    }
}

// MARK: - Relational Risk Tier Card (Figma Frame 58:3)
public struct RelationalRiskTierCard: View {
    public let badgeTitle: String
    public let badgeColor: Color
    public let scoreRange: String
    public let explanation: String
    
    public init(
        badgeTitle: String,
        badgeColor: Color,
        scoreRange: String,
        explanation: String
    ) {
        self.badgeTitle = badgeTitle
        self.badgeColor = badgeColor
        self.scoreRange = scoreRange
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
