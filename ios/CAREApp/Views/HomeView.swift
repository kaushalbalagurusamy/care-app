import SwiftUI


// MARK: - Screen 2: Homepage & Dashboard View (Figma Frame 5:4)
public struct HomeView: View {
    public let router: AppRouter
    
    public init(router: AppRouter) {
        self.router = router
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Modular Compact Header Bar (Flush with Top, Sparkle Between Chart & Profile on Right)
            HeaderNavBar(
                showBackButton: false,
                showHomeButton: true,
                showSparkleButton: true,
                sparklePlacement: .right
            )
            
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
                        router.navigate(to: .education)
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
                        router.navigate(to: .exercises)
                    }
                )
                
                // Assessment Interval Capsule Pill Anchored at Bottom with Centered Calendar Icon
                StreakBadgeView(daysUntilNextAssessment: 3)
                    .padding(.bottom, 2)
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background.ignoresSafeArea())
    }
}

// MARK: - Previews
#Preview("Home View") {
    HomeView(router: AppRouter())
}
