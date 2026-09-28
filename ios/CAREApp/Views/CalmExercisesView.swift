import SwiftUI

// MARK: - Screen: Calm Exercises (Figma Frame 270:4 & Node 239:8)
public struct CalmExercisesView: View {
    @Environment(AppRouter.self) private var router: AppRouter?
    
    @State private var searchText: String = ""
    @State private var selectedTab: String = "All"
    @State private var exercises: [ExerciseItem] = ExerciseItem.sampleCalmExercises
    @State private var sortOption: ExerciseSortOption = .mostRecentlyCompleted
    @State private var isShowingSortSheet: Bool = false
    
    public init() {}
    
    private var filteredExercises: [ExerciseItem] {
        var items = exercises
        if !searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            items = items.filter { $0.title.localizedCaseInsensitiveContains(searchText) || $0.subtitle.localizedCaseInsensitiveContains(searchText) }
        }
        if selectedTab == "Favorites" {
            items = items.filter { $0.isFavorite }
        }
        
        switch sortOption {
        case .mostRecentlyCompleted:
            return items
        case .numberOfTimesCompleted:
            return items.sorted { $0.timesCompleted > $1.timesCompleted }
        case .highestRated:
            return items.sorted { $0.ratingStars > $1.ratingStars }
        case .longestDuration, .shortestDuration:
            return items
        }
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            HeaderNavBar(
                showBackButton: true,
                showHomeButton: true,
                showSparkleButton: true,
                showChartButton: true,
                showProfileButton: true,
                onBack: { router?.pop() }
            )
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    
                    // Title Section
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Calm")
                            .font(Theme.Typography.screenTitle)
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        Text("Exercises for feeling safe, grounded & connected.")
                            .font(Theme.Typography.poppins(.regular, size: 14))
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                    .padding(.top, Theme.Spacing.headerTitleSpacing)
                    
                    // Search Bar with Sort Filter Button
                    HStack(spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(Theme.Colors.textSecondary)
                            TextField("Search exercises...", text: $searchText)
                                .font(Theme.Typography.poppins(.regular, size: 14))
                        }
                        .padding(.horizontal, 14)
                        .frame(height: 44)
                        .background(Color(hex: "#F1F5F9"))
                        .cornerRadius(12)
                        
                        Button(action: {
                            isShowingSortSheet = true
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(hex: "#F1F5F9"))
                                    .frame(width: 44, height: 44)
                                Image(systemName: "slider.horizontal.3")
                                    .foregroundColor(Theme.Colors.textPrimary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    
                    // Filter Tabs Row
                    HStack(spacing: 8) {
                        ForEach(["All", "Favorites", "Recent", "Most Used"], id: \.self) { tab in
                            Button(action: {
                                selectedTab = tab
                            }) {
                                Text(tab)
                                    .font(Theme.Typography.poppins(selectedTab == tab ? .semiBold : .regular, size: 13))
                                    .foregroundColor(selectedTab == tab ? .white : Theme.Colors.textSecondary)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 7)
                                    .background(selectedTab == tab ? Theme.Colors.primary : Color(hex: "#F1F5F9"))
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    
                    // Progress & Streak Card
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("14")
                                .font(Theme.Typography.poppins(.bold, size: 22))
                                .foregroundColor(Theme.Colors.textPrimary)
                            Text("exercises completed")
                                .font(Theme.Typography.poppins(.regular, size: 12))
                                .foregroundColor(Theme.Colors.textSecondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("This week  3/7")
                                .font(Theme.Typography.poppins(.semiBold, size: 13))
                                .foregroundColor(Theme.Colors.primary)
                            Text("3 day streak 🔥")
                                .font(Theme.Typography.poppins(.medium, size: 12))
                                .foregroundColor(Color(hex: "#EA580C"))
                        }
                    }
                    .padding(16)
                    .background(Color(hex: "#F8FAFC"))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(hex: "#E2E8F0"), lineWidth: 1)
                    )
                    
                    // Exercise Cards Stack
                    VStack(spacing: 14) {
                        ForEach(filteredExercises) { item in
                            exerciseCard(item)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            
            // Pinned Bottom Button
            VStack(spacing: 0) {
                Button(action: {
                    router?.navigate(to: .personalizedActionPlan)
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 15, weight: .semibold))
                        Text("Unlock Full Book Exercises")
                            .font(Theme.Typography.buttonLabel)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .foregroundColor(.white)
                    .background(Color(hex: "#1E293B"))
                    .cornerRadius(18)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.white.ignoresSafeArea(edges: .bottom))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background.ignoresSafeArea())
        .sheet(isPresented: $isShowingSortSheet) {
            ExerciseSortSheet(
                selectedOption: $sortOption,
                onApply: { _ in isShowingSortSheet = false },
                onCancel: { isShowingSortSheet = false }
            )
        }
    }
    
    @ViewBuilder
    private func exerciseCard(_ item: ExerciseItem) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                HStack(spacing: 8) {
                    Text(item.emoji)
                        .font(.system(size: 22))
                    Text(item.title)
                        .font(Theme.Typography.poppins(.bold, size: 16))
                        .foregroundColor(Theme.Colors.textPrimary)
                }
                
                Spacer()
                
                Button(action: {
                    if let idx = exercises.firstIndex(where: { $0.id == item.id }) {
                        exercises[idx].isFavorite.toggle()
                    }
                }) {
                    Image(systemName: item.isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 18))
                        .foregroundColor(item.isFavorite ? .red : Theme.Colors.textSecondary)
                }
                .buttonStyle(.plain)
            }
            
            Text(item.subtitle)
                .font(Theme.Typography.poppins(.regular, size: 13.5))
                .foregroundColor(Theme.Colors.textSecondary)
                .lineSpacing(2)
            
            HStack {
                Text("\(item.durationMinutesRange) • \(item.timesCompleted) times completed • Last done: \(item.lastCompletedDate ?? "Never")")
                    .font(Theme.Typography.poppins(.regular, size: 11.5))
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            
            HStack {
                HStack(spacing: 3) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= item.ratingStars ? "star.fill" : "star")
                            .font(.system(size: 11))
                            .foregroundColor(Color(hex: "#F59E0B"))
                    }
                    Text("Your rating")
                        .font(Theme.Typography.poppins(.regular, size: 11))
                        .foregroundColor(Theme.Colors.textSecondary)
                        .padding(.leading, 4)
                }
                
                Spacer()
                
                Button(action: {
                    navigateToExercise(item)
                }) {
                    Text("Do Exercise")
                        .font(Theme.Typography.poppins(.semiBold, size: 13))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Theme.Colors.primary)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color(hex: "#E2E8F0"), lineWidth: 1)
                )
        )
    }
    
    private func navigateToExercise(_ item: ExerciseItem) {
        if item.id == "watch-something-funny" {
            router?.navigate(to: .watchFunny)
        } else if item.id == "keep-photo-close" {
            router?.navigate(to: .keepPhoto)
        } else {
            router?.navigate(to: .exercises)
        }
    }
}

#Preview {
    CalmExercisesView()
}
