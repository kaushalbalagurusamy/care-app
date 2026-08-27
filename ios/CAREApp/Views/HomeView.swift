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
            
            // Main Dashboard Body - Filling Full Vertical Height with Uniform Spacing
            VStack(alignment: .leading, spacing: 14) {
                
                // Welcome Title (Matching Figma Frame 5:19 Poppins Bold 24pt)
                Text("Welcome Back")
                    .font(Theme.Typography.welcomeTitle)
                    .foregroundColor(Theme.Colors.textPrimary)
                    .padding(.top, 2)
                
                // 3 Action Cards (Original Photos) with Uniform Spacing
                ActionCardView(
                    imageName: "card_education_full",
                    title: "Education",
                    subtitle: "Learn Wellness",
                    action: {
                        activeAlert = .education
                    }
                )
                
                ActionCardView(
                    imageName: "card_assessment_full",
                    title: "Assessment",
                    subtitle: "Track Mind",
                    action: {
                        router.navigate(to: .assessmentOverview)
                    }
                )
                
                ActionCardView(
                    imageName: "card_exercises_full",
                    title: "Exercises",
                    subtitle: "Active Care",
                    action: {
                        activeAlert = .exercises
                    }
                )
                
                // Daily Streak Capsule Pill Anchored at Bottom with Same Uniform Spacing
                StreakBadgeView(daysCount: 5)
                    .padding(.bottom, 2)
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
}

// MARK: - Previews
#Preview("Home View") {
    HomeView(router: AppRouter())
}
