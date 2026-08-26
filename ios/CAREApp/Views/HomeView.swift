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
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Welcome Title (Matching Figma Frame 5:19)
                    Text("Welcome Back")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Theme.Colors.textPrimary)
                        .padding(.top, 4)
                    
                    // 3 Action Cards (Matching Figma 350x196 frames)
                    VStack(spacing: 16) {
                        // Module 01: Education
                        ActionCardView(
                            number: "01",
                            title: "Education",
                            subtitle: "Learn Wellness",
                            iconSystemName: "book.fill",
                            backgroundImageName: "card_education_bg",
                            action: {
                                activeAlert = .education
                            }
                        )
                        
                        // Module 02: Assessment (Primary Flow)
                        ActionCardView(
                            number: "02",
                            title: "Assessment",
                            subtitle: "Track Mind",
                            iconSystemName: "heart.fill",
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
                            iconSystemName: "bolt.fill",
                            backgroundImageName: "card_exercises_bg",
                            action: {
                                activeAlert = .exercises
                            }
                        )
                    }
                    
                    // Daily Streak Capsule Pill (Matching Figma Frame 5:47)
                    StreakBadgeView(daysCount: 5)
                        .padding(.top, 4)
                        .padding(.bottom, 24)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
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
