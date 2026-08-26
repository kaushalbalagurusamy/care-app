import SwiftUI

// MARK: - Screen 3: Assessment Overview & Domain Intro (Figma Frame 11:4)
public struct AssessmentOverviewView: View {
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
                    Text("C.A.R.E. Assessment")
                        .font(Theme.Typography.title)
                        .foregroundColor(Theme.Colors.textPrimary)
                        .padding(.top, 8)
                    
                    // Main Content Bubble Envelope
                    BubbleCardContainer(title: "Understanding C.A.R.E.") {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("The C.A.R.E. assessment evaluates four neurobiological dimensions of relational health, offering actionable insight into your social baseline.")
                                .font(Theme.Typography.body)
                                .foregroundColor(Theme.Colors.textSecondary)
                            
                            Divider()
                                .background(Theme.Colors.dividerSubtle)
                            
                            // 4 Domain Summary Rows
                            ForEach(CAREDomain.allCases, id: \.self) { domain in
                                HStack(alignment: .top, spacing: 14) {
                                    // Letter Circle Badge
                                    Text(domain.letter)
                                        .font(Theme.Typography.headline)
                                        .foregroundColor(.white)
                                        .frame(width: 36, height: 36)
                                        .background(domain.themeColor)
                                        .clipShape(Circle())
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(domain.subtitle)
                                            .font(Theme.Typography.cardTitle)
                                            .foregroundColor(Theme.Colors.textPrimary)
                                        
                                        Text(domain.explanation)
                                            .font(Theme.Typography.caption)
                                            .foregroundColor(Theme.Colors.textSecondary)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Action Button
                    PrimaryButton(title: "Begin the Survey", icon: "arrow.right") {
                        router.navigate(to: .surveyOverview)
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
#Preview("Assessment Overview View") {
    AssessmentOverviewView(router: AppRouter())
}
