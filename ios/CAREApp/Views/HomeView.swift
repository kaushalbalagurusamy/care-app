import SwiftUI


// MARK: - Screen 2: Homepage & Dashboard View (Figma Frame 5:4 & 244:470)
public struct HomeView: View {
    public let router: AppRouter
    @Binding public var activeSession: AssessmentSessionState?
    public var onDiscardAssessment: (() -> Void)?
    
    public init(
        router: AppRouter,
        activeSession: Binding<AssessmentSessionState?> = .constant(nil),
        onDiscardAssessment: (() -> Void)? = nil
    ) {
        self.router = router
        self._activeSession = activeSession
        self.onDiscardAssessment = onDiscardAssessment
    }
    
    private var isAssessmentInProgress: Bool {
        activeSession?.hasStarted == true
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
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    
                    // Welcome Title (Matching Figma Frame 5:19 Poppins Bold 24pt)
                    Text("Welcome Back")
                        .font(Theme.Typography.welcomeTitle)
                        .foregroundColor(Theme.Colors.textPrimary)
                        .padding(.top, 2)
                    
                    // Top Weekly Exercise Tracker (Figma Frame 5:4 Updated & Directive 18+)
                    DailyExerciseTrackerView()
                    
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
                        hasResumeControls: isAssessmentInProgress,
                        onResume: {
                            router.navigate(to: .surveyQuestion)
                        },
                        onDiscard: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                activeSession = nil
                                onDiscardAssessment?()
                            }
                        },
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
                        .padding(.bottom, 12)
                }
                .padding(.horizontal, 20)
            }
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
