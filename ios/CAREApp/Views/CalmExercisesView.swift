import SwiftUI

// Figma frames 582:227, 509:94, 506:95 and 520:94 share this layout.
public struct CalmExercisesView: View {
    public init() {}
    public var body: some View { ExerciseCategoryHomeView(category: .calm) }
}

public struct ExerciseCategoryHomeView: View {
    @Environment(AppRouter.self) private var router: AppRouter?
    @Environment(ExerciseProgressStore.self) private var progress: ExerciseProgressStore?
    @Environment(AppEnvironment.self) private var appEnvironment: AppEnvironment?

    public let category: ExerciseCategory
    @State private var searchText = ""
    @State private var selectedTab = "All"
    @State private var sortOption: ExerciseSortOption = .mostRecentlyCompleted
    @State private var isShowingSortSheet = false
    @State private var isShowingUpcomingAlert = false
    @State private var draftError: String?

    public init(category: ExerciseCategory) { self.category = category }

    private var accent: Color { category.accentColor }

    private var soft: Color {
        switch category {
        case .calm: return Color(hex: "#EAF4FF")
        case .accepted: return Color(hex: "#EDFBF8")
        case .resonant: return Color(hex: "#F4F1FF")
        case .energetic: return Color(hex: "#FFF5EA")
        }
    }

    private var cardStripe: Color {
        switch category {
        case .calm: return Color(hex: "#93C5FD")
        case .accepted: return Color(hex: "#99F6E4")
        case .resonant: return Color(hex: "#D8B4FE")
        case .energetic: return Color(hex: "#FED7AA")
        }
    }

    private var subtitle: String {
        switch category {
        case .calm: return "Exercises for feeling safe, grounded & connected."
        case .accepted: return "Exercises for feeling included, valued & connected."
        case .resonant: return "Exercises for noticing and mirroring emotions."
        case .energetic: return "Exercises for supporting a healthy reward system."
        }
    }

    private var exercises: [ExerciseItem] { ExerciseItem.allExercises.filter { $0.category == category } }
    private func record(_ id: String) -> ExerciseProgressRecord { progress?.record(for: id) ?? .init() }

    private var displayedExercises: [ExerciseItem] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        var items = exercises.filter {
            query.isEmpty || $0.title.localizedCaseInsensitiveContains(query) || $0.subtitle.localizedCaseInsensitiveContains(query)
        }
        if selectedTab == "Favorites" { items = items.filter { record($0.id).isFavorite } }
        // Recent and Most Used are sort shortcuts. Choosing a sheet option returns to All
        // (or keeps Favorites as a filter), so the requested order is always visible.
        let effectiveSort: ExerciseSortOption
        switch selectedTab {
        case "Recent": effectiveSort = .mostRecentlyCompleted
        case "Most Used": effectiveSort = .numberOfTimesCompleted
        default: effectiveSort = sortOption
        }
        return ExerciseSortEngine.sorted(items, by: effectiveSort, records: progress?.records ?? [:])
    }

    public var body: some View {
        VStack(spacing: 0) {
            HeaderNavBar(accentColor: accent, onBack: { router?.pop() })
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 13) {
                    Text(category.rawValue)
                        .font(Theme.Typography.screenTitle)
                        .foregroundColor(Theme.Colors.textPrimary)
                        .padding(.top, Theme.Spacing.headerTitleSpacing)
                    Text(subtitle)
                        .font(Theme.Typography.screenSubtitle)
                        .foregroundColor(Theme.Colors.textSecondary)
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                        TextField("Search exercises...", text: $searchText).autocorrectionDisabled()
                        Button { isShowingSortSheet = true } label: {
                            Image(systemName: "slider.horizontal.3").font(.system(size: 17, weight: .semibold))
                        }
                        .accessibilityLabel("Sort exercises")
                        .accessibilityIdentifier("ExerciseSortButton")
                    }
                    .font(Theme.Typography.poppins(.regular, size: 13))
                    .foregroundColor(Theme.Colors.textSecondary)
                    .padding(.horizontal, 12)
                    .frame(height: 36)
                    .background(soft)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    HStack(spacing: 6) {
                        ForEach(["All", "Favorites", "Recent", "Most Used"], id: \.self) { tab in
                            Button { selectedTab = tab } label: {
                                Text(tab)
                                    .font(Theme.Typography.poppins(.medium, size: 12))
                                    .foregroundColor(selectedTab == tab ? .white : Theme.Colors.textPrimary)
                                    .padding(.horizontal, 12)
                                    .frame(height: 32)
                                    .background(selectedTab == tab ? accent : soft)
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    progressCard
                    if displayedExercises.isEmpty {
                        Text(selectedTab == "Favorites" ? "Tap a heart to save an exercise here." : "No exercises found.")
                            .font(Theme.Typography.poppins(.regular, size: 13))
                            .foregroundColor(Theme.Colors.textSecondary)
                            .frame(maxWidth: .infinity, minHeight: 90)
                    } else {
                        ForEach(displayedExercises) { item in exerciseCard(item) }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .background(.white)
        .sheet(isPresented: $isShowingSortSheet) {
            ExerciseSortSheet(selectedOption: $sortOption, onApply: { _ in
                if selectedTab == "Recent" || selectedTab == "Most Used" { selectedTab = "All" }
                isShowingSortSheet = false
            }, onCancel: { isShowingSortSheet = false }, accent: accent)
        }
        .alert("Coming soon", isPresented: $isShowingUpcomingAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("This exercise will be available soon.")
        }
        .alert("Could not update exercise", isPresented: Binding(get: { draftError != nil }, set: { if !$0 { draftError = nil } })) {
            Button("OK", role: .cancel) { draftError = nil }
        } message: { Text(draftError ?? "") }
    }

    private var progressCard: some View {
        let completed = progress?.completionCount(for: category) ?? 0
        let week = progress?.weekCompletedDays(for: category) ?? 0
        let streak = progress?.currentStreak(for: category) ?? 0
        return HStack(alignment: .center, spacing: 14) {
            VStack(alignment: .leading, spacing: 2) {
                Text("\(completed)")
                    .font(Theme.Typography.poppins(.bold, size: 27))
                    .foregroundColor(accent)
                Text("exercises completed")
                    .font(Theme.Typography.poppins(.regular, size: 11))
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            Spacer()
            Rectangle().fill(Color(hex: "#DCE4EE")).frame(width: 1, height: 44)
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text("This week")
                    Spacer()
                    Text("\(week)/7")
                }
                .font(Theme.Typography.poppins(.semiBold, size: 10))
                .foregroundColor(accent)
                GeometryReader { geo in
                    Capsule().fill(Color(hex: "#DCE4EE"))
                        .overlay(alignment: .leading) {
                            Capsule().fill(accent).frame(width: geo.size.width * min(CGFloat(week) / 7, 1))
                        }
                }
                .frame(height: 4)
                HStack(spacing: 3) {
                    Text("\(streak) day streak")
                    ExerciseEmojiView(emoji: "🔥", size: 12)
                    if streak >= 7 { Text("Nice work!") }
                }
                .font(Theme.Typography.poppins(.medium, size: 10))
                .foregroundColor(Color(hex: "#EA580C"))
            }
            .frame(maxWidth: 145)
        }
        .padding(14)
        .background(soft)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func exerciseCard(_ item: ExerciseItem) -> some View {
        let entry = record(item.id)
        let lastCompleted = entry.completionDates.max()
        return VStack(alignment: .leading, spacing: 7) {
            HStack(alignment: .center) {
                ExerciseEmojiView(emoji: item.emoji, size: 24)
                Text(item.title)
                    .font(Theme.Typography.poppins(.bold, size: 13))
                    .foregroundColor(Theme.Colors.textPrimary)
                Spacer()
                Button { progress?.toggleFavorite(item.id) } label: {
                    Image(systemName: entry.isFavorite ? "heart.fill" : "heart").foregroundColor(accent)
                }
                .accessibilityLabel(entry.isFavorite ? "Remove from favorites" : "Add to favorites")
            }
            Text(item.subtitle)
                .font(Theme.Typography.poppins(.regular, size: 11))
                .foregroundColor(Theme.Colors.textSecondary)
            Divider()
            Text(lastCompleted.map { "\(item.durationMinutesRange) • \(entry.completionDates.count) times completed • Last done: \($0.formatted(date: .abbreviated, time: .omitted))" } ?? "\(item.durationMinutesRange) • New exercise")
                .font(Theme.Typography.poppins(.regular, size: 10))
                .foregroundColor(Theme.Colors.textSecondary)
            HStack(spacing: 3) {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= entry.rating ? "star.fill" : "star")
                        .font(.system(size: 10))
                        .foregroundColor(entry.rating == 0 ? Theme.Colors.textSecondary : Color(hex: "#F5A600"))
                }
                Text(entry.rating == 0 ? "Not yet rated" : "Your rating")
                    .font(Theme.Typography.poppins(.regular, size: 10))
                    .foregroundColor(Theme.Colors.textSecondary)
                Spacer()
                Button {
                    navigateToExercise(item.id)
                } label: {
                    Label("Do Exercise", systemImage: "arrow.right")
                        .font(Theme.Typography.poppins(.semiBold, size: 10))
                        .foregroundColor(.white)
                        .padding(.horizontal, 9)
                        .frame(height: 29)
                        .background(accent)
                        .clipShape(RoundedRectangle(cornerRadius: 9))
                }
                .accessibilityIdentifier("DoExercise_\(item.id)")
            }
        }
        .padding(.leading, 20)
        .padding(.trailing, 14)
        .padding(.vertical, 14)
        .background(soft)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(cardStripe)
                .frame(width: 6)
        }
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay {
            if appEnvironment?.draftStore.exercise(for: item.id) != nil {
                InProgressCardOverlay(title: "Exercise in progress", cornerRadius: 18, onContinue: {
                    navigateToExercise(item.id)
                }, onDiscard: {
                    do { try appEnvironment?.draftStore.discardExercise(item.id) }
                    catch { draftError = "This exercise could not be discarded. Please try again." }
                })
            }
        }
    }

    private func navigateToExercise(_ id: String) {
        switch id {
        case "watch-something-funny": router?.navigate(to: .watchFunny)
        case "keep-photo-close": router?.navigate(to: .keepPhoto)
        case "belonging-list": router?.navigate(to: .belongingList)
        case "share-something-small": router?.navigate(to: .shareSomethingSmall)
        case "mirror-emotion": router?.navigate(to: .mirrorEmotion)
        case "mirror-loved-one": router?.navigate(to: .mirrorLovedOne)
        case "share-something-new": router?.navigate(to: .shareSomethingNew)
        case "connection-countdown": router?.navigate(to: .connectionCountdown)
        default: isShowingUpcomingAlert = true
        }
    }
}
