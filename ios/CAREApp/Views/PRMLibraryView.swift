import SwiftUI
import PhotosUI

// Figma frame 932:106 — Positive Relational Moments Library.
public struct PRMLibraryView: View {
    @Environment(AppRouter.self) private var router: AppRouter?
    @Environment(AppEnvironment.self) private var appEnvironment: AppEnvironment?
    @State private var searchText = ""
    @State private var selectedFilter: MomentFilter = .all
    @State private var selectedCategory: ExerciseCategory?
    @State private var saveError: String?

    public init() {}

    private enum MomentFilter: String, CaseIterable {
        case all = "All"
        case favorites = "Favorites"
        case recent = "Recent"
        case lastViewed = "Last Viewed"
    }

    private var visibleMoments: [PRMSavedMoment] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        var moments = (appEnvironment?.draftStore.savedMoments ?? []).filter {
            (selectedCategory == nil || $0.category == selectedCategory) &&
            (query.isEmpty || $0.title.localizedCaseInsensitiveContains(query) ||
                $0.summary.localizedCaseInsensitiveContains(query) ||
                $0.answers.contains { $0.response.localizedCaseInsensitiveContains(query) } ||
                $0.category.rawValue.localizedCaseInsensitiveContains(query))
        }
        switch selectedFilter {
        case .all, .recent: moments.sort { $0.savedAt > $1.savedAt }
        case .favorites: moments = moments.filter(\.isFavorite)
        case .lastViewed:
            moments = moments.filter { $0.lastViewedAt != nil }
            moments.sort { ($0.lastViewedAt ?? .distantPast) > ($1.lastViewedAt ?? .distantPast) }
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
        .alert("Could not save moment", isPresented: Binding(
            get: { saveError != nil }, set: { if !$0 { saveError = nil } }
        )) { Button("OK", role: .cancel) { saveError = nil } }
            message: { Text(saveError ?? "") }
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
            Menu {
                Button {
                    selectedCategory = nil
                } label: {
                    if selectedCategory == nil { Label("All categories", systemImage: "checkmark") }
                    else { Text("All categories") }
                }
                ForEach(ExerciseCategory.allCases) { category in
                    Button {
                        selectedCategory = category
                    } label: {
                        if selectedCategory == category { Label(category.rawValue, systemImage: "checkmark") }
                        else { Text(category.rawValue) }
                    }
                }
            } label: {
                HStack(spacing: 5) {
                    if let selectedCategory {
                        Text(selectedCategory.rawValue)
                            .font(Theme.Typography.poppins(.medium, size: 11))
                    }
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 18, weight: .medium))
                }
                .frame(minWidth: 36, minHeight: 36)
                .contentShape(Rectangle())
            }
            .accessibilityLabel("Filter by category")
            .accessibilityIdentifier("PRMCategoryFilter")
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

    private func momentCard(_ moment: PRMSavedMoment) -> some View {
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
                    do { try appEnvironment?.draftStore.updateMoment(moment.id) { $0.isFavorite.toggle() } }
                    catch { saveError = "Your favorite could not be saved. Please try again." }
                } label: {
                    Image(systemName: moment.isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(moment.isFavorite ? colors.action : Theme.Colors.textSecondary)
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(moment.isFavorite ? "Remove from favorites" : "Add to favorites")
            }
            Text(moment.summary)
                .font(Theme.Typography.poppins(.regular, size: 11.5))
                .foregroundColor(Theme.Colors.textSecondary)
                .lineSpacing(2)
                .frame(maxWidth: .infinity, minHeight: 32, alignment: .topLeading)
            Rectangle()
                .fill(Color(hex: "#D8E0E9"))
                .frame(height: 1)
            Text("\(moment.category.rawValue.uppercased())  •  Saved \(moment.savedAt.formatted(.dateTime.month(.abbreviated).day()))")
                .font(Theme.Typography.poppins(.regular, size: 10.5))
                .foregroundColor(Theme.Colors.textSecondary)
            HStack {
                Text("A moment to revisit")
                    .font(Theme.Typography.poppins(.regular, size: 11))
                    .foregroundColor(Theme.Colors.textSecondary)
                Spacer()
                Button {
                    do {
                        try appEnvironment?.draftStore.updateMoment(moment.id) { $0.lastViewedAt = .now }
                        router?.navigate(to: .prmMoment(moment.id))
                    } catch { saveError = "This moment could not be opened. Please try again." }
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
             selectedCategory != nil ? "No \(selectedCategory!.rawValue) moments yet." :
             searchText.isEmpty ? "Complete a PRM exercise to save your first moment." : "No moments found.")
            .font(Theme.Typography.poppins(.regular, size: 13))
            .foregroundColor(Theme.Colors.textSecondary)
            .frame(maxWidth: .infinity, minHeight: 120)
    }

}

// A saved moment presents only what the person entered, without exercise instructions.
public struct PRMMomentDetailView: View {
    @Environment(AppRouter.self) private var router: AppRouter?
    @Environment(AppEnvironment.self) private var appEnvironment: AppEnvironment?
    public let momentID: UUID
    @State private var editingReflection: Int?
    @State private var isEditingDescription = false
    @State private var draftResponses: [String] = []
    @State private var descriptionDraft = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var replacementPhoto: UIImage?
    @State private var pendingLeave: (() -> Void)?
    @State private var showingUnsavedPrompt = false
    @State private var saveError: String?
    @State private var showingDeleteConfirmation = false

    public init(momentID: UUID) { self.momentID = momentID }
    private var moment: PRMSavedMoment? { appEnvironment?.draftStore.savedMoments.first { $0.id == momentID } }
    private var hasUnsavedChanges: Bool {
        guard let moment else { return false }
        return replacementPhoto != nil ||
            descriptionDraft != moment.photoDescription ||
            draftResponses != moment.answers.map(\.response)
    }

    public var body: some View {
        let accent = moment?.category.accentColor ?? ExerciseCategory.calm.accentColor
        VStack(spacing: 0) {
            HeaderNavBar(accentColor: accent,
                onBack: { attemptLeave { router?.pop() } },
                onHome: { attemptLeave { router?.popToRoot() } },
                onLibrary: { attemptLeave { router?.navigate(to: .prmLibrary) } },
                onSparkle: { attemptLeave { router?.navigate(to: .personalizedActionPlan) } },
                onChart: { attemptLeave { router?.navigate(to: .pastResults) } },
                onProfile: { attemptLeave { router?.navigate(to: .profile) } })
            if let moment {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        HStack(spacing: 12) {
                            ExerciseEmojiView(emoji: moment.emoji, size: 36)
                                .frame(width: 58, height: 58)
                                .background(accent.opacity(0.1), in: Circle())
                            VStack(alignment: .leading, spacing: 5) {
                                Text("\(moment.category.rawValue.uppercased())  •  PRM")
                                    .font(Theme.Typography.poppins(.semiBold, size: 11)).foregroundColor(accent)
                                Text(moment.title)
                                    .font(Theme.Typography.poppins(.bold, size: 23))
                                    .foregroundColor(Theme.Colors.textPrimary)
                            }
                            Spacer(minLength: 0)
                            Button { toggleFavorite() } label: {
                                Image(systemName: moment.isFavorite ? "heart.fill" : "heart")
                                    .font(.system(size: 22)).foregroundColor(accent)
                            }
                            .accessibilityLabel(moment.isFavorite ? "Remove from favorites" : "Add to favorites")
                        }
                        Text("Saved \(moment.savedAt.formatted(.dateTime.month(.wide).day().year()))")
                            .font(Theme.Typography.poppins(.regular, size: 12))
                            .foregroundColor(Theme.Colors.textSecondary)

                        if let image = replacementPhoto ?? savedPhoto(moment) {
                            Image(uiImage: image).resizable().scaledToFit()
                                .frame(maxWidth: .infinity).frame(maxHeight: 300)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .accessibilityLabel("Saved moment photo")
                        }
                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            Label(moment.photoFilename == nil && replacementPhoto == nil ? "Add a photo" : "Choose a different photo",
                                  systemImage: "photo.on.rectangle")
                                .font(Theme.Typography.poppins(.semiBold, size: 13))
                                .foregroundColor(accent)
                        }
                        .accessibilityIdentifier("ChangePRMPhoto")
                        if moment.photoFilename != nil || replacementPhoto != nil {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("About this photo")
                                    .font(Theme.Typography.poppins(.semiBold, size: 15))
                                if isEditingDescription {
                                    TextField("Add a description (optional)", text: $descriptionDraft, axis: .vertical)
                                        .lineLimit(2...5).padding(10)
                                        .background(.white, in: RoundedRectangle(cornerRadius: 10))
                                    Button("Done editing") { isEditingDescription = false }.foregroundColor(accent)
                                } else {
                                    if !descriptionDraft.isEmpty { Text(descriptionDraft) }
                                    Button(descriptionDraft.isEmpty ? "Add a description" : "Edit description") {
                                        isEditingDescription = true
                                    }.foregroundColor(accent)
                                }
                            }
                            .font(Theme.Typography.poppins(.regular, size: 13))
                            .padding(16).frame(maxWidth: .infinity, alignment: .leading)
                            .background(accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
                        }

                        if !moment.answers.isEmpty {
                            Text("Your reflections")
                                .font(Theme.Typography.poppins(.bold, size: 17))
                            ForEach(Array(moment.answers.enumerated()), id: \.offset) { index, answer in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(answer.question)
                                        .font(Theme.Typography.poppins(.semiBold, size: 13))
                                        .foregroundColor(Theme.Colors.textPrimary)
                                    if editingReflection == index && draftResponses.indices.contains(index) {
                                        TextField("Your reflection", text: $draftResponses[index], axis: .vertical)
                                            .lineLimit(2...6)
                                            .font(Theme.Typography.poppins(.regular, size: 14))
                                            .padding(10)
                                            .background(.white, in: RoundedRectangle(cornerRadius: 10))
                                    } else {
                                        Text(draftResponses.indices.contains(index) ? draftResponses[index] : answer.response)
                                            .font(Theme.Typography.poppins(.regular, size: 14))
                                            .foregroundColor(Theme.Colors.textSecondary)
                                    }
                                    Button(editingReflection == index ? "Done editing" : "Edit reflection") {
                                        editingReflection = editingReflection == index ? nil : index
                                    }
                                    .font(Theme.Typography.poppins(.semiBold, size: 12))
                                    .foregroundColor(accent)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(16)
                                .background(accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
                            }
                        } else {
                            Text("No written reflection was added to this moment.")
                                .font(Theme.Typography.poppins(.regular, size: 13))
                                .foregroundColor(Theme.Colors.textSecondary)
                        }
                        if hasUnsavedChanges {
                            Button("Save changes") { _ = saveChanges() }
                                .font(Theme.Typography.poppins(.semiBold, size: 14))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, minHeight: 44)
                                .background(accent, in: RoundedRectangle(cornerRadius: 12))
                                .accessibilityIdentifier("SavePRMMomentChanges")
                        }
                        Button("Delete Moment", role: .destructive) { showingDeleteConfirmation = true }
                            .font(Theme.Typography.poppins(.medium, size: 12))
                            .foregroundColor(.red)
                            .padding(.top, 12)
                            .accessibilityIdentifier("DeletePRMMoment")
                    }
                    .padding(.horizontal, 20).padding(.top, 16).padding(.bottom, 30)
                }
            } else {
                Text("This saved moment is unavailable.")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(.white)
        .onAppear { loadDraft() }
        .onChange(of: moment?.id) { _, _ in loadDraft() }
        .onChange(of: selectedPhoto) { _, item in
            guard let item else { return }
            Task { await stagePhoto(item) }
        }
        .alert("Save changes to this moment?", isPresented: $showingUnsavedPrompt) {
            Button("Save and Leave") {
                if saveChanges() { completePendingLeave() }
            }
            Button("Discard Changes", role: .destructive) { completePendingLeave() }
            Button("Keep Editing", role: .cancel) { pendingLeave = nil }
        } message: {
            Text("Your edits to this positive relational moment have not been saved.")
        }
        .alert("Could not save moment", isPresented: Binding(
            get: { saveError != nil }, set: { if !$0 { saveError = nil } }
        )) { Button("OK", role: .cancel) { saveError = nil } }
            message: { Text(saveError ?? "") }
        .confirmationDialog("Delete this saved moment?", isPresented: $showingDeleteConfirmation) {
            Button("Delete Moment", role: .destructive) {
                do {
                    try appEnvironment?.draftStore.deleteMoment(momentID)
                    router?.pop()
                } catch { saveError = "The moment could not be deleted. Please try again." }
            }
        } message: {
            Text("Its photo and reflections will no longer appear in your library.")
        }
    }

    private func savedPhoto(_ moment: PRMSavedMoment) -> UIImage? {
        guard let filename = moment.photoFilename,
              let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return UIImage(contentsOfFile: documents.appendingPathComponent("ExercisePhotos")
            .appendingPathComponent(filename).path)
    }
    private func toggleFavorite() {
        do { try appEnvironment?.draftStore.updateMoment(momentID) { $0.isFavorite.toggle() } }
        catch { saveError = "Your favorite could not be saved. Please try again." }
    }
    private func loadDraft() {
        guard let moment else { return }
        draftResponses = moment.answers.map(\.response)
        descriptionDraft = moment.photoDescription
    }
    private func attemptLeave(_ action: @escaping () -> Void) {
        guard hasUnsavedChanges else { action(); return }
        pendingLeave = action
        showingUnsavedPrompt = true
    }
    private func completePendingLeave() {
        let action = pendingLeave
        pendingLeave = nil
        action?()
    }
    @MainActor
    private func stagePhoto(_ item: PhotosPickerItem) async {
        do {
            guard let data = try await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: data) else { throw CocoaError(.fileReadCorruptFile) }
            replacementPhoto = image
        } catch { saveError = "The photo could not be opened. Please choose another photo." }
    }
    @discardableResult
    private func saveChanges() -> Bool {
        guard let moment, let store = appEnvironment?.draftStore else { return false }
        guard draftResponses.count == moment.answers.count else {
            saveError = "This moment is still loading. Please try again."
            return false
        }
        var newPhotoURL: URL?
        do {
            if let replacementPhoto {
                guard let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
                      let data = replacementPhoto.jpegData(compressionQuality: 0.82) else {
                    throw CocoaError(.fileWriteUnknown)
                }
                let directory = documents.appendingPathComponent("ExercisePhotos", isDirectory: true)
                try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
                let url = directory.appendingPathComponent(UUID().uuidString + ".jpg")
                try data.write(to: url, options: .atomic)
                newPhotoURL = url
            }
            let responses = draftResponses
            let description = descriptionDraft
            let filename = newPhotoURL?.lastPathComponent
            try store.updateMoment(momentID) { saved in
                saved.answers = zip(moment.answers, responses).map {
                    PRMMomentAnswer(question: $0.0.question, response: $0.1)
                }
                saved.photoDescription = description
                if let filename { saved.photoFilename = filename }
            }
            replacementPhoto = nil
            isEditingDescription = false
            editingReflection = nil
            return true
        } catch {
            if let newPhotoURL { try? FileManager.default.removeItem(at: newPhotoURL) }
            saveError = "Your changes could not be saved. Please try again."
            return false
        }
    }
}
