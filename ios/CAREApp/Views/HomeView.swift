import SwiftUI

// MARK: - Home Alert Items
enum HomeAlertItem: Identifiable {
    case education
    case exercises
    
    var id: String {
        switch self {
        case .education: return "education"
        case .exercises: return "exercises"
        }
    }
    
    var title: String {
        switch self {
        case .education: return "Education Module"
        case .exercises: return "Exercises Module"
        }
    }
    
    var message: String {
        switch self {
        case .education: return "The interactive wellness education modules are scheduled for the next release."
        case .exercises: return "Daily relational exercises and co-regulation tools will be available soon."
        }
    }
}

// MARK: - Screen 2: Homepage & Dashboard View (Figma Frame 5:4)
public struct HomeView: View {
    public let router: AppRouter
    @State private var activeAlert: HomeAlertItem? = nil
    
    public init(router: AppRouter) {
        self.router = router
    }
    
    public var body: some View {
        GeometryReader { geo in
            let screenHeight = geo.size.height
            let verticalSpacing = computeSpacing(for: screenHeight)
            let cardMaxHeight = computeCardHeight(availableHeight: screenHeight, spacing: verticalSpacing)
            
            VStack(spacing: 0) {
                // Modular Compact Header Bar (Flush with Top)
                HeaderNavBar(
                    showBackButton: false,
                    showHomeButton: true,
                    showChartButton: true,
                    showProfileButton: true,
                    onHome: {},
                    onChart: { router.navigate(to: .pastResults) },
                    onProfile: {}
                )
                
                // Main Dashboard Body - Proportionally Scaled to Fit Whole Screen
                VStack(alignment: .leading, spacing: verticalSpacing) {
                    
                    // Welcome Title (Matching Figma Frame 5:19 Poppins Bold 24pt)
                    Text("Welcome Back")
                        .font(Theme.Typography.welcomeTitle)
                        .foregroundColor(Theme.Colors.textPrimary)
                        .padding(.top, 2)
                    
                    // 3 Action Cards with Original Figma Photos & Proportional Scaling
                    ActionCardView(
                        imageName: "card_education_full",
                        title: "Education",
                        subtitle: "Learn Wellness",
                        maxHeight: cardMaxHeight,
                        action: {
                            activeAlert = .education
                        }
                    )
                    
                    ActionCardView(
                        imageName: "card_assessment_full",
                        title: "Assessment",
                        subtitle: "Track Mind",
                        maxHeight: cardMaxHeight,
                        action: {
                            router.navigate(to: .assessmentOverview)
                        }
                    )
                    
                    ActionCardView(
                        imageName: "card_exercises_full",
                        title: "Exercises",
                        subtitle: "Active Care",
                        maxHeight: cardMaxHeight,
                        action: {
                            activeAlert = .exercises
                        }
                    )
                    
                    // Daily Streak Capsule Pill Scaled with Viewport
                    StreakBadgeView(daysCount: 5)
                        .padding(.bottom, 4)
                }
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .background(Theme.Colors.background.ignoresSafeArea())
        .alert(
            activeAlert?.title ?? "",
            isPresented: Binding(
                get: { activeAlert != nil },
                set: { if !$0 { activeAlert = nil } }
            ),
            actions: {
                Button("OK", role: .cancel) { activeAlert = nil }
            },
            message: {
                Text(activeAlert?.message ?? "")
            }
        )
    }
    
    private func computeSpacing(for height: CGFloat) -> CGFloat {
        if height > 750 {
            return 12.0
        } else if height > 650 {
            return 10.0
        } else {
            return 8.0
        }
    }
    
    private func computeCardHeight(availableHeight: CGFloat, spacing: CGFloat) -> CGFloat {
        let overhead: CGFloat = 52.0 + 30.0 + 42.0 + (spacing * 4.0) + 8.0
        let remaining = max(availableHeight - overhead, 0)
        let perCard = remaining / 3.0
        return min(perCard, 196.0)
    }
}

// MARK: - Previews
#Preview("Home View") {
    HomeView(router: AppRouter())
}
