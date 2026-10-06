import SwiftUI

// Figma frame 932:106 — Positive Relational Moments Library.
public struct PRMLibraryView: View {
    @Environment(AppRouter.self) private var router: AppRouter?
    @State private var searchText = ""
    @State private var selectedFilter: MomentFilter = .all
    @State private var favoriteIDs: Set<String> = ["photo-close"]
    @State private var viewedDates: [String: Date] = [:]
    @State private var selectedMoment: PreviewMoment?

    public init() {}

    private enum MomentFilter: String, CaseIterable {
        case all = "All"
        case favorites = "Favorites"
        case recent = "Recent"
        case lastViewed = "Last Viewed"
    }

    // These are the example moments shown in the Figma review screen. Real saved
    // moments will come from the PRM storage flow when that flow is implemented.
    private struct PreviewMoment: Identifiable {
        let id: String
        let title: String
        let emoji: String
        let detail: String
        let category: ExerciseCategory
        let savedLabel: String
        let savedOrder: Int
    }

    private var previewMoments: [PreviewMoment] {
        #if DEBUG
        return [
            .init(id: "photo-close", title: "Keep a Photo Close", emoji: "📷", detail: "That afternoon at the lake when Dad and I laughed together.", category: .calm, savedLabel: "Saved today", savedOrder: 0),
            .init(id: "share-small", title: "Share Something Small", emoji: "💬", detail: "Maya listened when I told her about my day. I felt understood.", category: .accepted, savedLabel: "Saved yesterday", savedOrder: 1),
            .init(id: "friendly-exchange", title: "Notice a Friendly Exchange", emoji: "✨", detail: "The barista remembered my name and made me smile.", category: .calm, savedLabel: "Saved 3 days ago", savedOrder: 2)
        ]
        #else
        return []
        #endif
    }

    private var visibleMoments: [PreviewMoment] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        var moments = previewMoments.filter {
            query.isEmpty || $0.title.localizedCaseInsensitiveContains(query) ||
                $0.detail.localizedCaseInsensitiveContains(query) ||
                $0.category.rawValue.localizedCaseInsensitiveContains(query)
        }
        switch selectedFilter {
        case .all: break
        case .favorites: moments = moments.filter { favoriteIDs.contains($0.id) }
        case .recent: moments.sort { $0.savedOrder < $1.savedOrder }
        case .lastViewed:
            moments = moments.filter { viewedDates[$0.id] != nil }
            moments.sort { (viewedDates[$0.id] ?? .distantPast) > (viewedDates[$1.id] ?? .distantPast) }
        }
        return moments
    }

    public var body: some View {
        VStack(spacing: 0) {
            HeaderNavBar(accentColor: Color(hex: "#246BB8"), onBack: { router?.pop() })
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    heading
                    searchBar
                    filterChips
                    HStack {
                        Text("Saved moments")
                            .font(Theme.Typography.poppins(.semiBold, size: 14))
                            .foregroundColor(Theme.Colors.textPrimary)
                        Spacer()
                        Text("\(visibleMoments.count) \(visibleMoments.count == 1 ? "moment" : "moments")")
                            .font(Theme.Typography.poppins(.medium, size: 10))
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                    .frame(height: 27)
                    if visibleMoments.isEmpty {
                        emptyState
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(visibleMoments) { moment in momentCard(moment) }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 30)
            }
        }
        .background(.white)
        .sheet(item: $selectedMoment) { moment in
            momentDetail(moment)
                .presentationDetents([.medium])
        }
    }

    private var heading: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Positive Relational\nMoments Library")
                .font(Theme.Typography.poppins(.bold, size: 24))
                .lineSpacing(0)
                .foregroundColor(Theme.Colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            Text("Revisit moments that help you feel connected.")
                .font(Theme.Typography.poppins(.regular, size: 13))
                .foregroundColor(Theme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
            TextField("Search moments...", text: $searchText)
                .font(Theme.Typography.poppins(.regular, size: 13))
                .autocorrectionDisabled()
                .accessibilityIdentifier("SearchMoments")
            Image(systemName: "slider.horizontal.3")
                .font(.system(size: 18, weight: .medium))
                .accessibilityHidden(true)
        }
        .foregroundColor(Theme.Colors.textSecondary)
        .padding(.horizontal, 12)
        .frame(height: 40)
        .background(Color(hex: "#EBF5FF"), in: RoundedRectangle(cornerRadius: 12))
    }

    private var filterChips: some View {
        HStack(spacing: 5) {
            ForEach(MomentFilter.allCases, id: \.self) { filter in
                Button { selectedFilter = filter } label: {
                    Text(filter.rawValue)
                        .font(Theme.Typography.poppins(selectedFilter == filter ? .semiBold : .medium, size: 13))
                        .foregroundColor(selectedFilter == filter ? .white : Theme.Colors.textPrimary)
                        .padding(.horizontal, 16)
                        .frame(height: 36)
                        .background(selectedFilter == filter ? Color(hex: "#246BB8") : Color(hex: "#EBF5FF"), in: Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityIdentifier("MomentFilters")
    }

    private func momentCard(_ moment: PreviewMoment) -> some View {
        let colors = cardColors(for: moment.category)
        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                ExerciseEmojiView(emoji: moment.emoji, size: 24)
                    .frame(width: 24, height: 24)
                Text(moment.title)
                    .font(Theme.Typography.poppins(.bold, size: 14))
                    .foregroundColor(Theme.Colors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                Spacer(minLength: 0)
                Button {
                    if favoriteIDs.contains(moment.id) { favoriteIDs.remove(moment.id) }
                    else { favoriteIDs.insert(moment.id) }
                } label: {
                    Image(systemName: favoriteIDs.contains(moment.id) ? "heart.fill" : "heart")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(favoriteIDs.contains(moment.id) ? colors.action : Theme.Colors.textSecondary)
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(favoriteIDs.contains(moment.id) ? "Remove from favorites" : "Add to favorites")
            }
            Text(moment.detail)
                .font(Theme.Typography.poppins(.regular, size: 11.5))
                .foregroundColor(Theme.Colors.textSecondary)
                .lineSpacing(2)
                .frame(maxWidth: .infinity, minHeight: 32, alignment: .topLeading)
            Rectangle()
                .fill(Color(hex: "#D8E0E9"))
                .frame(height: 1)
            Text("\(moment.category.rawValue.uppercased())  •  \(moment.savedLabel)")
                .font(Theme.Typography.poppins(.regular, size: 10.5))
                .foregroundColor(Theme.Colors.textSecondary)
            HStack {
                Text("A moment to revisit")
                    .font(Theme.Typography.poppins(.regular, size: 11))
                    .foregroundColor(Theme.Colors.textSecondary)
                Spacer()
                Button {
                    viewedDates[moment.id] = .now
                    selectedMoment = moment
                } label: {
                    HStack(spacing: 4) {
                        Text("View Moment")
                        Image(systemName: "arrow.right")
                    }
                    .font(Theme.Typography.poppins(.semiBold, size: 11))
                    .foregroundColor(.white)
                    .frame(width: 130, height: 33)
                    .background(colors.action, in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .padding(.leading, 6)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(colors.background)
        .overlay(alignment: .leading) {
            colors.stripe.frame(width: 6)
        }
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func cardColors(for category: ExerciseCategory) -> (background: Color, stripe: Color, action: Color) {
        switch category {
        case .calm: return (Color(hex: "#EBF5FF"), Color(hex: "#93C5FD"), Color(hex: "#246BB8"))
        case .accepted: return (Color(hex: "#F0FDFB"), Color(hex: "#99F6E4"), Color(hex: "#2D9F7F"))
        case .resonant: return (Color(hex: "#F4F1FF"), Color(hex: "#D8B4FE"), category.accentColor)
        case .energetic: return (Color(hex: "#FFF5EA"), Color(hex: "#FED7AA"), category.accentColor)
        }
    }

    private var emptyState: some View {
        Text(selectedFilter == .lastViewed ? "Moments you open will appear here." :
             selectedFilter == .favorites ? "Favorite a moment to see it here." :
             searchText.isEmpty ? "Your saved moments will appear here." : "No moments found.")
            .font(Theme.Typography.poppins(.regular, size: 13))
            .foregroundColor(Theme.Colors.textSecondary)
            .frame(maxWidth: .infinity, minHeight: 120)
    }

    private func momentDetail(_ moment: PreviewMoment) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(moment.emoji).font(.system(size: 32))
            Text(moment.title)
                .font(Theme.Typography.poppins(.bold, size: 22))
                .foregroundColor(Theme.Colors.textPrimary)
            Text(moment.detail)
                .font(Theme.Typography.poppins(.regular, size: 16))
                .foregroundColor(Theme.Colors.textSecondary)
            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardColors(for: moment.category).background)
    }
}
