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
            HeaderNavBar(showBackButton: false)
            
            // Main Dashboard Body - Filling Full Vertical Height with Uniform Spacing
            VStack(alignment: .leading, spacing: 14) {
                
                // Welcome Title (Matching Figma Frame 5:19 Poppins Bold 24pt)
                Text("Welcome Back")
                    .font(Theme.Typography.welcomeTitle)
                    .foregroundColor(Theme.Colors.textPrimary)
                    .padding(.top, 2)
                
                // 3 Action Cards (Clean 3D Art, Midpoint Icons, 50% Larger Titles)
                ActionCardView(
                    title: "Education",
                    subtitle: "Learn Wellness",
                    iconName: "icon_book_open",
                    backgroundImageName: "card_education_bg",
                    action: {
                        activeAlert = .education
                    }
                )
                
                ActionCardView(
                    title: "Assessment",
                    subtitle: "Track Mind",
                    iconName: "icon_heart_pulse",
                    backgroundImageName: "card_assessment_bg",
                    action: {
                        router.navigate(to: .assessmentOverview)
                    }
                )
                
                ActionCardView(
                    title: "Exercises",
                    subtitle: "Active Care",
                    iconName: "icon_activity",
                    backgroundImageName: "card_exercises_bg",
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
