import SwiftUI

// MARK: - Screen 4: Survey Instructions & Onboarding (Figma Frame 13:4)
public struct SurveyOverviewView: View {
    public let router: AppRouter
    
    public init(router: AppRouter) {
        self.router = router
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header Bar
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
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Title Section
                    Text("Survey Instructions")
                        .font(Theme.Typography.title)
                        .foregroundColor(Theme.Colors.textPrimary)
                        .padding(.top, 8)
                    
                    // Instructions Bubble Container
                    BubbleCardContainer(title: "How to Answer Accurately") {
                        VStack(alignment: .leading, spacing: 20) {
                            
                            // DO Section
                            VStack(alignment: .leading, spacing: 12) {
                                Label("DO", systemImage: "checkmark.circle.fill")
                                    .font(Theme.Typography.cardTitle)
                                    .foregroundColor(Theme.Colors.Safety.lowRisk)
                                
                                InstructionBullet(
                                    icon: "checkmark",
                                    color: Theme.Colors.Safety.lowRisk,
                                    text: "Answer based on your recent interactions over the past 30 days."
                                )
                                InstructionBullet(
                                    icon: "checkmark",
                                    color: Theme.Colors.Safety.lowRisk,
                                    text: "Reflect on your autonomic response and how you physically feel around each person."
                                )
                                InstructionBullet(
                                    icon: "checkmark",
                                    color: Theme.Colors.Safety.lowRisk,
                                    text: "Be honest with yourself—there are no right or wrong answers."
                                )
                            }
                            
                            Divider()
                                .background(Theme.Colors.dividerSubtle)
                            
                            // DON'T Section
                            VStack(alignment: .leading, spacing: 12) {
                                Label("DON'T", systemImage: "xmark.circle.fill")
                                    .font(Theme.Typography.cardTitle)
                                    .foregroundColor(Theme.Colors.Safety.highRisk)
                                
                                InstructionBullet(
                                    icon: "xmark",
                                    color: Theme.Colors.Safety.highRisk,
                                    text: "Don't base answers on who you wish the person was or ideal scenarios."
                                )
                                InstructionBullet(
                                    icon: "xmark",
                                    color: Theme.Colors.Safety.highRisk,
                                    text: "Don't overthink individual items—go with your initial bodily instinct."
                                )
                                InstructionBullet(
                                    icon: "xmark",
                                    color: Theme.Colors.Safety.highRisk,
                                    text: "Don't complete the survey in the immediate aftermath of an acute disagreement."
                                )
                            }
                        }
                    }
                    
                    // Action Button
                    PrimaryButton(title: "Choose Relationships", icon: "arrow.right") {
                        router.navigate(to: .chooseRelationships)
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

// MARK: - Instruction Bullet Row
struct InstructionBullet: View {
    let icon: String
    let color: Color
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(color)
                .frame(width: 18, height: 18)
            
            Text(text)
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Previews
#Preview("Survey Overview View") {
    SurveyOverviewView(router: AppRouter())
}
