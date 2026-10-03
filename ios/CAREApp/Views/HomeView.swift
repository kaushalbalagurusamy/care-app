import SwiftUI


// MARK: - Screen 2: Homepage & Dashboard View (Figma Frame 5:4 & 244:470)
public struct HomeView: View {
    @Environment(ExerciseProgressStore.self) private var exerciseProgress: ExerciseProgressStore?
    @Environment(AppEnvironment.self) private var appEnvironment: AppEnvironment?
    @Environment(ProfileSettingsStore.self) private var profileSettings: ProfileSettingsStore?
    @State private var draftError: String?
    public let router: AppRouter
    @Binding public var activeSession: AssessmentSessionState?
    public var onDiscardAssessment: (() -> Void)?
    public let latestAssessmentDate: Date?
    public let selectionInProgress: Bool
    
    public init(
        router: AppRouter,
        activeSession: Binding<AssessmentSessionState?> = .constant(nil),
        onDiscardAssessment: (() -> Void)? = nil,
        latestAssessmentDate: Date? = nil,
        selectionInProgress: Bool = false
    ) {
        self.router = router
        self._activeSession = activeSession
        self.onDiscardAssessment = onDiscardAssessment
        self.latestAssessmentDate = latestAssessmentDate
        self.selectionInProgress = selectionInProgress
    }
    
    private var isAssessmentInProgress: Bool {
        activeSession.map { AssessmentSessionState.canStart(with: $0.participants) } == true || selectionInProgress
    }

    private var exerciseDays: [DailyExerciseTrackerView.DayStatus] {
        let completed = exerciseProgress?.weekStatuses() ?? Array(repeating: false, count: 7)
        let today = (Calendar.current.component(.weekday, from: .now) + 5) % 7
        return ["M", "T", "W", "T", "F", "S", "S"].enumerated().map { index, label in
            .init(id: index, label: label, isCompleted: completed[index], isCurrent: index == today)
        }
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Modular compact header bar
            HeaderNavBar(
                showBackButton: false,
                showHomeButton: true
            )
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 8) {
                    
                    // Welcome Title (Matching Figma Frame 5:19 Poppins Bold 24pt, 50%+ more top spacing)
                    Text("Welcome Back")
                        .font(Theme.Typography.welcomeTitle)
                        .foregroundColor(Theme.Colors.textPrimary)
                        .padding(.top, Theme.Spacing.headerTitleSpacing)
                    
                    // Top Weekly Exercise Tracker (Figma Frame 5:4 Updated & Directive 18+)
                    DailyExerciseTrackerView(
                        completedDaysCount: exerciseProgress?.weekCompletedDays() ?? 0,
                        days: exerciseDays
                    )
                    
                    // 3 Action Cards (Compact 149pt height, Bottom-Left Titles, Grayscale Images)
                    ActionCardView(
                        title: "Education",
                        iconName: "icon_book_open",
                        backgroundImageName: "card_education_bg",
                        hasResumeControls: appEnvironment?.draftStore.mostRecentQuizSlug != nil,
                        onResume: { resumeQuiz() },
                        onDiscard: {
                            guard let slug = appEnvironment?.draftStore.mostRecentQuizSlug else { return }
                            do { try appEnvironment?.draftStore.discardQuiz(for: slug) }
                            catch { draftError = "The quiz could not be discarded. Please try again." }
                        },
                        action: {
                            router.navigate(to: .education)
                        }
                    )
                    
                    ActionCardView(
                        title: "Assessment",
                        iconName: "icon_heart_pulse",
                        backgroundImageName: "card_assessment_bg",
                        hasResumeControls: isAssessmentInProgress,
                        onResume: {
                            router.navigate(to: activeSession == nil ? .chooseRelationships : .surveyQuestion)
                        },
                        onDiscard: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                onDiscardAssessment?()
                            }
                        },
                        action: {
                            router.navigate(to: .assessmentOverview)
                        }
                    )
                    
                    ActionCardView(
                        title: "Exercises",
                        iconName: "icon_activity",
                        backgroundImageName: "card_exercises_bg",
                        hasResumeControls: appEnvironment?.draftStore.mostRecentExerciseID != nil,
                        onResume: { resumeExercise() },
                        onDiscard: {
                            guard let id = appEnvironment?.draftStore.mostRecentExerciseID else { return }
                            do { try appEnvironment?.draftStore.discardExercise(id) }
                            catch { draftError = "The exercise could not be discarded. Please try again." }
                        },
                        action: {
                            router.navigate(to: .exercises)
                        }
                    )
                    
                    // Assessment Interval Capsule Pill Anchored at Bottom with Centered Calendar Icon
                    if let daysUntilNextAssessment {
                        StreakBadgeView(daysUntilNextAssessment: daysUntilNextAssessment)
                            .padding(.top, 2)
                            .padding(.bottom, 8)
                    } else {
                        Label("Complete your first assessment to start your schedule", systemImage: "calendar")
                            .font(Theme.Typography.poppins(.medium, size: 13))
                            .foregroundStyle(Theme.Colors.textSecondary)
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .background(Theme.Colors.cardSurface, in: Capsule())
                            .padding(.bottom, 8)
                    }
                }
                .padding(.horizontal, 20)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background.ignoresSafeArea())
        .alert("Could not update progress", isPresented: Binding(get: { draftError != nil }, set: { if !$0 { draftError = nil } })) {
            Button("OK", role: .cancel) { draftError = nil }
        } message: { Text(draftError ?? "") }
    }

    private var daysUntilNextAssessment: Int? {
        guard let latestAssessmentDate else { return nil }
        let interval: Int
        switch profileSettings?.frequency ?? "biweekly" {
        case "2x/week": interval = 3
        case "1x/week": interval = 7
        case "monthly": interval = 30
        case "every 3 months": interval = 90
        default: interval = 14
        }
        guard let dueDate = Calendar.current.date(byAdding: .day, value: interval, to: latestAssessmentDate) else { return nil }
        return max(0, Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: .now), to: Calendar.current.startOfDay(for: dueDate)).day ?? 0)
    }

    private func resumeQuiz() {
        guard let slug = appEnvironment?.draftStore.mostRecentQuizSlug,
              let topic = (try? EducationManifestLoader.loadBundledManifest())?.first(where: { $0.slug == slug }) else {
            draftError = "That quiz is unavailable. Open Education to start another."
            return
        }
        router.navigate(to: .educationQuiz(topic: topic))
    }

    private func resumeExercise() {
        guard let id = appEnvironment?.draftStore.mostRecentExerciseID else { return }
        switch id {
        case "watch-something-funny": router.navigate(to: .watchFunny)
        case "keep-photo-close": router.navigate(to: .keepPhoto)
        case "belonging-list": router.navigate(to: .belongingList)
        case "share-something-small": router.navigate(to: .shareSomethingSmall)
        case "mirror-emotion": router.navigate(to: .mirrorEmotion)
        case "mirror-loved-one": router.navigate(to: .mirrorLovedOne)
        case "share-something-new": router.navigate(to: .shareSomethingNew)
        case "connection-countdown": router.navigate(to: .connectionCountdown)
        default: draftError = "That exercise is unavailable. Open Exercises to choose another."
        }
    }
}

// MARK: - Previews
#Preview("Home View") {
    HomeView(router: AppRouter())
}
