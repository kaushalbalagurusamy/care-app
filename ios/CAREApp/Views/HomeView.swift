import SwiftUI

// MARK: - Screen 2: Homepage & Dashboard View (Figma Frame 5:4)
public struct HomeView: View {
    public let router: AppRouter
    @State private var showingEducationAlert = false
    @State private var showingExercisesAlert = false
    
    public init(router: AppRouter) {
        self.router = router
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            HeaderNavBar(
                showBackButton: false,
                showHomeButton: true,
                showChartButton: true,
                showProfileButton: true,
                onHome: {},
                onChart: { router.navigate(to: .pastResults) },
                onProfile: {}
            )
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // Welcome & Greeting
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Welcome Back,")
                            .font(Theme.Typography.subheadline)
                            .foregroundColor(Theme.Colors.textSecondary)
                        
                        Text("Sarah Mitchell")
                            .font(Theme.Typography.title)
                            .foregroundColor(Theme.Colors.textPrimary)
                    }
                    .padding(.top, 8)
                    
                    // Streak Widget
                    StreakBadgeView(daysCount: 5)
                    
                    // Dashboard Modules List
                    VStack(spacing: 16) {
                        // Module 01: Education
                        ActionCardView(
                            number: "01",
                            title: "Education",
                            subtitle: "Learn Wellness",
                            backgroundImageName: "card_education_bg",
                            action: {
                                showingEducationAlert = true
                            }
                        )
                        
                        // Module 02: Assessment (Primary Flow)
                        ActionCardView(
                            number: "02",
                            title: "Assessment",
                            subtitle: "Track Mind",
                            backgroundImageName: "card_assessment_bg",
                            action: {
                                router.navigate(to: .assessmentOverview)
                            }
                        )
                        
                        // Module 03: Exercises
                        ActionCardView(
                            number: "03",
                            title: "Exercises",
                            subtitle: "Active Care",
                            backgroundImageName: "card_exercises_bg",
                            action: {
                                showingExercisesAlert = true
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
        .background(Theme.Colors.background)
        .alert("Education Module", isPresented: $showingEducationAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("The interactive wellness education modules are scheduled for the next release.")
        }
        .alert("Exercises Module", isPresented: $showingExercisesAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Daily relational exercises and co-regulation tools will be available soon.")
        }
    }
}

// MARK: - Previews
#Preview("Home View") {
    HomeView(router: AppRouter())
}
