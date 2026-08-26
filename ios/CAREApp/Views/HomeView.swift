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
    
    // Equal 14pt vertical spacing throughout entire column matching Figma
    private let uniformSpacing: CGFloat = 14.0
    
    public init(router: AppRouter) {
        self.router = router
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Modular Compact Header Bar (52pt) with Direct Figma Icons & Poppins Font
            HeaderNavBar(
                showBackButton: false,
                showHomeButton: true,
                showChartButton: true,
                showProfileButton: true,
                onHome: {},
                onChart: { router.navigate(to: .pastResults) },
                onProfile: {}
            )
            
            // Main Dashboard Body - Fitted with Uniform Spacing
            VStack(alignment: .leading, spacing: uniformSpacing) {
                
                // Welcome Title (Matching Figma Frame 5:19 Poppins Bold 24pt)
                Text("Welcome Back")
                    .font(Theme.Typography.welcomeTitle)
                    .foregroundColor(Theme.Colors.textPrimary)
                    .padding(.top, 4)
                
                // 3 Action Cards (Direct Figma Exports)
                ActionCardView(
                    imageName: "card_education_full",
                    action: {
                        activeAlert = .education
                    }
                )
                
                ActionCardView(
                    imageName: "card_assessment_full",
                    action: {
                        router.navigate(to: .assessmentOverview)
                    }
                )
                
                ActionCardView(
                    imageName: "card_exercises_full",
                    action: {
                        activeAlert = .exercises
                    }
                )
                
                // Daily Streak Capsule Pill with Exactly Equal Spacing (14pt) & Direct Figma Sparkles
                StreakBadgeView(daysCount: 5)
                    .padding(.bottom, 6)
            }
            .padding(.horizontal, 20)
        }
        .background(Theme.Colors.background)
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
}

// MARK: - Previews
#Preview("Home View") {
    HomeView(router: AppRouter())
}
