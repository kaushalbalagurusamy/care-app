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
    @Environment(CAREPremiumAccess.self) private var premium: CAREPremiumAccess?

    public let category: ExerciseCategory
    @State private var searchText = ""
    @State private var selectedTab = "All"
    @State private var sortOption: ExerciseSortOption = .mostRecentlyCompleted
    @State private var participationFilter: ExerciseParticipationFilter = .any
    @State private var prmOnly = false
    @State private var isShowingSortSheet = false
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

    private var exercises: [ExerciseItem] {
        (premium?.hasAccess == true ? ExerciseItem.allExercises : ExerciseItem.freeExercises)
            .filter { $0.category == category }
    }
    private func record(_ id: String) -> ExerciseProgressRecord { progress?.record(for: id) ?? .init() }

    private var displayedExercises: [ExerciseItem] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        var items = exercises.filter {
            query.isEmpty || $0.title.localizedCaseInsensitiveContains(query) || $0.subtitle.localizedCaseInsensitiveContains(query)
        }
        if selectedTab == "Favorites" { items = items.filter { record($0.id).isFavorite } }
        switch participationFilter {
        case .any: break
        case .onePerson: items = items.filter { !$0.requiresTwoPeople }
        case .twoPeople: items = items.filter(\.requiresTwoPeople)
        }
        if prmOnly { items = items.filter(\.isPositiveRelationalMoment) }
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
            Button { router?.navigate(to: .personalizedActionPlan) } label: {
                Label(premium?.hasAccess == true ? "View Your C.A.R.E. Action Plan" : "Unlock Your C.A.R.E. Action Plan", systemImage: "sparkles")
                    .font(Theme.Typography.poppins(.semiBold, size: 14))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(accent)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(.white)
        }
        .background(.white)
        .sheet(isPresented: $isShowingSortSheet) {
            ExerciseSortSheet(selectedOption: $sortOption,
                              participationFilter: $participationFilter,
                              prmOnly: $prmOnly,
                              onApply: { _ in
                if selectedTab == "Recent" || selectedTab == "Most Used" { selectedTab = "All" }
                isShowingSortSheet = false
            }, onCancel: { isShowingSortSheet = false }, accent: accent)
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
            HStack(alignment: .top, spacing: 12) {
                ExerciseEmojiView(emoji: item.emoji, size: 28)
                    .frame(width: 42, height: 42)
                    .background(.white.opacity(0.7), in: Circle())
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .top, spacing: 8) {
                        Text(item.title)
                            .font(Theme.Typography.poppins(.bold, size: 14))
                            .foregroundColor(Theme.Colors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 0)
                        Button { progress?.toggleFavorite(item.id) } label: {
                            Image(systemName: entry.isFavorite ? "heart.fill" : "heart")
                                .foregroundColor(accent)
                                .frame(width: 26, height: 26)
                        }
                        .accessibilityLabel(entry.isFavorite ? "Remove from favorites" : "Add to favorites")
                    }
                    Text(item.subtitle)
                        .font(Theme.Typography.poppins(.regular, size: 11))
                        .foregroundColor(Theme.Colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                    if item.isPositiveRelationalMoment || item.requiresTwoPeople {
                        HStack(spacing: 6) {
                            if item.isPositiveRelationalMoment {
                                traitBadge("PRM", colors: prmBadgeColors)
                            }
                            if item.requiresTwoPeople {
                                traitBadge("Requires 2 people", colors: twoPeopleBadgeColors)
                            }
                        }
                        .padding(.top, 3)
                    }
                }
            }
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

    private var prmBadgeColors: (fill: String, text: String, border: String) {
        switch category {
        case .calm: return ("#DCEEFF", "#1F66B1", "#A8D2FF")
        case .accepted: return ("#DFF7EE", "#1F8065", "#A8E6D1")
        case .resonant: return ("#F0EBFF", "#6652A8", "#CFC2F2")
        case .energetic: return ("#FFF0DB", "#A65C1F", "#F5D1A8")
        }
    }

    private var twoPeopleBadgeColors: (fill: String, text: String, border: String) {
        switch category {
        case .calm: return ("#C9E3FF", "#164F8B", "#7CB6F0")
        case .accepted: return ("#C3EFDE", "#12694E", "#7FD6B5")
        case .resonant: return ("#DDD2FB", "#503A91", "#B39CE8")
        case .energetic: return ("#F5D5AE", "#8A420E", "#DAA66A")
        }
    }

    private func traitBadge(_ title: String, colors: (fill: String, text: String, border: String)) -> some View {
        Text(title)
            .font(Theme.Typography.poppins(.semiBold, size: 10))
            .foregroundStyle(Color(hex: colors.text))
            .padding(.horizontal, 9)
            .frame(height: 24)
            .background(Color(hex: colors.fill), in: Capsule())
            .overlay(Capsule().stroke(Color(hex: colors.border), lineWidth: 1))
            .accessibilityLabel(title == "PRM" ? "Positive Relational Moment exercise" : title)
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
        default: router?.navigate(to: .guidedExercise(id))
        }
    }
}
