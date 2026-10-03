import SwiftUI

// MARK: - Screen 20: Exercises Hub View (Figma Frame 214:4)
public struct ExercisesView: View {
    @Environment(ExerciseProgressStore.self) private var exerciseProgress: ExerciseProgressStore?
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
                accentColor: Theme.Colors.Domains.calmAccent,
                title: nil
            )
            
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    // Title & Subtitle Header
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Exercises")
                            .font(Theme.Typography.screenTitle)
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        Text("Strengthen your relational neural pathways")
                            .font(Theme.Typography.screenSubtitle)
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                    .padding(.top, Theme.Spacing.headerTitleSpacing)

                    DailyExerciseTrackerView(
                        completedDaysCount: exerciseProgress?.weekCompletedDays() ?? 0,
                        days: exerciseDays
                    )
                    
                    // 4 Pathway Cards
                    VStack(spacing: 10) {
                        ExercisePathwayCard(
                            letter: "C",
                            title: "Calm",
                            description: "Fosters down-regulation of stress systems, developing neural pathways toward safety and emotional grounding.",
                            color: ExerciseCategory.calm.accentColor,
                            badgeColor: ExerciseCategory.calm.badgeColor,
                            action: { router.navigate(to: .calmExercises) }
                        )
                        
                        ExercisePathwayCard(
                            letter: "A",
                            title: "Accepted",
                            description: "Feeling valued, validated, and safely connected within healthy, supportive relationship cultures.",
                            color: ExerciseCategory.accepted.accentColor,
                            badgeColor: ExerciseCategory.accepted.badgeColor,
                            action: { router.navigate(to: .acceptedExercises) }
                        )
                        
                        ExercisePathwayCard(
                            letter: "R",
                            title: "Resonant",
                            description: "Activating mirror neurons to sense and dynamically align with another's emotional state without losing yourself.",
                            color: ExerciseCategory.resonant.accentColor,
                            badgeColor: ExerciseCategory.resonant.badgeColor,
                            action: { router.navigate(to: .resonantExercises) }
                        )
                        
                        ExercisePathwayCard(
                            letter: "E",
                            title: "Energetic",
                            description: "The vitalizing emotional flow and neurochemical boost generated through growth-fostering, mutual bonds.",
                            color: ExerciseCategory.energetic.accentColor,
                            badgeColor: ExerciseCategory.energetic.badgeColor,
                            action: { router.navigate(to: .energeticExercises) }
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background.ignoresSafeArea())
    }

    private var exerciseDays: [DailyExerciseTrackerView.DayStatus] {
        let completed = exerciseProgress?.weekStatuses() ?? Array(repeating: false, count: 7)
        let today = (Calendar.current.component(.weekday, from: .now) + 5) % 7
        return ["M", "T", "W", "T", "F", "S", "S"].enumerated().map { index, label in
            .init(id: index, label: label, isCompleted: completed[index], isCurrent: index == today)
        }
    }
}

// MARK: - Exercise Pathway Card Component
public struct ExercisePathwayCard: View {
    public let letter: String
    public let title: String
    public let description: String
    public let color: Color
    public let badgeColor: Color
    public let action: () -> Void
    
    public init(letter: String, title: String, description: String, color: Color, badgeColor: Color, action: @escaping () -> Void = {}) {
        self.letter = letter
        self.title = title
        self.description = description
        self.color = color
        self.badgeColor = badgeColor
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
        HStack(alignment: .center, spacing: 12) {
            // Circular Letter Badge (44x44)
            ZStack {
                Circle()
                    .fill(badgeColor)
                    .frame(width: 40, height: 40)
                
                Text(letter)
                    .font(Theme.Typography.poppins(.bold, size: 18))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(Theme.Typography.poppins(.semiBold, size: 14))
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Text(description)
                    .font(Theme.Typography.poppins(.regular, size: 10.5))
                    .foregroundColor(Theme.Colors.textSecondary)
                    .lineLimit(3)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 27, height: 27)
                .background(.white, in: Circle())
        }
        .padding(12)
        .frame(height: 96)
        .background(Theme.Colors.cardSurface)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Theme.Colors.dividerSubtle, lineWidth: 1)
        )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}

// MARK: - Previews
#Preview("Exercises Hub View") {
    ExercisesView(router: AppRouter())
}
