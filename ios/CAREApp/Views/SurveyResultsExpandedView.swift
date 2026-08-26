import SwiftUI

// MARK: - Screen 9: Relational Risk Groups Deep Dive Modal (Figma Frame 58:3)
public struct SurveyResultsExpandedView: View {
    public let router: AppRouter
    
    public init(router: AppRouter) {
        self.router = router
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Modal Header with Dismiss X
            HStack {
                Spacer()
                
                Text("About Risk Groups")
                    .font(Theme.Typography.headline)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Spacer()
                
                Button(action: { router.pop() }) {
                    Circle()
                        .fill(Theme.Colors.surfaceSecondary)
                        .frame(width: 36, height: 36)
                        .overlay(
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Theme.Colors.textSecondary)
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .frame(height: 56)
            .background(Theme.Colors.background)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Title Section
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Understanding Relational Risk Groups")
                            .font(Theme.Typography.title)
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        Text("Your network's safety distribution directly impacts autonomic nervous system regulation and mental stamina.")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                    .padding(.top, 8)
                    
                    // 3 Risk Tier Deep-Dive Cards
                    VStack(spacing: 16) {
                        
                        // Tier 1: Safe Network
                        RiskTierExplanationCard(
                            tierName: "Safe Network",
                            scoreRange: "75 - 100",
                            tierColor: Theme.Colors.Safety.lowRisk,
                            tierBg: Theme.Colors.Safety.lowRiskBackground,
                            description: "Relationships in this tier serve as restorative anchors for your smart vagus nerve. Interactions promote co-regulation, emotional grounding, and reduced baseline cortisol levels."
                        )
                        
                        // Tier 2: Moderate Risk
                        RiskTierExplanationCard(
                            tierName: "Moderate Risk",
                            scoreRange: "60 - 74",
                            tierColor: Theme.Colors.Safety.moderateRisk,
                            tierBg: Theme.Colors.Safety.moderateRiskBackground,
                            description: "Relationships characterized by intermittent attunement or unspoken expectations. Proactive communication and mutual boundary check-ins prevent these bonds from drifting into relational strain."
                        )
                        
                        // Tier 3: High Risk
                        RiskTierExplanationCard(
                            tierName: "High Risk",
                            scoreRange: "0 - 59",
                            tierColor: Theme.Colors.Safety.highRisk,
                            tierBg: Theme.Colors.Safety.highRiskBackground,
                            description: "Bonds that trigger frequent sympathetic arousal (fight/flight) or dorsal shutdown. Prioritize clear energetic boundaries, post-interaction recovery, and intentional relational recalibration."
                        )
                    }
                    
                    // Action Button
                    PrimaryButton(title: "Dismiss") {
                        router.pop()
                    }
                    .padding(.top, 12)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
        .background(Theme.Colors.background)
    }
}

// MARK: - Risk Tier Explanation Card
struct RiskTierExplanationCard: View {
    let tierName: String
    let scoreRange: String
    let tierColor: Color
    let tierBg: Color
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(tierName)
                    .font(Theme.Typography.headline)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Spacer()
                
                Text(scoreRange)
                    .font(Theme.Typography.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(tierBg)
                    .foregroundColor(tierColor)
                    .clipShape(Capsule())
            }
            
            Text(description)
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .background(Theme.Colors.cardSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(tierColor.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Previews
#Preview("Survey Results Expanded View") {
    SurveyResultsExpandedView(router: AppRouter())
}
