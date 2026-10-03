import SwiftUI

// MARK: - Education Topics Hub View (Figma Frame 11: 122:4)
public struct EducationTopicsView: View {
    @Environment(AppRouter.self) private var router: AppRouter?
    @Environment(AppEnvironment.self) private var appEnvironment: AppEnvironment?
    
    public let topics: [EducationTopic]
    public let completedTopicSlugs: Set<EducationTopicSlug>
    public let onSelectTopic: ((EducationTopic) -> Void)?
    public let onBack: (() -> Void)?
    public let onHome: (() -> Void)?
    
    @State private var persistedCompletedSlugs: Set<EducationTopicSlug> = []
    @State private var draftError: String?
    
    public init(
        topics: [EducationTopic]? = nil,
        completedTopicSlugs: Set<EducationTopicSlug> = [],
        onSelectTopic: ((EducationTopic) -> Void)? = nil,
        onBack: (() -> Void)? = nil,
        onHome: (() -> Void)? = nil
    ) {
        if let topics = topics {
            self.topics = topics
        } else {
            self.topics = (try? EducationManifestLoader.loadBundledManifest()) ?? []
        }
        self.completedTopicSlugs = completedTopicSlugs
        self.onSelectTopic = onSelectTopic
        self.onBack = onBack
        self.onHome = onHome
    }
    
    private var effectiveCompletedSlugs: Set<EducationTopicSlug> {
        completedTopicSlugs.union(persistedCompletedSlugs)
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Standardized Top Navigation Bar (bypasses raw Figma Page 2 header vector)
            HeaderNavBar(
                showBackButton: true,
                showHomeButton: true,
                showChartButton: true,
                showProfileButton: true,
                onBack: onBack,
                onHome: onHome
            )
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    
                    // Screen Title & Subtitle Section (Matching Node 122:4)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Education")
                            .font(Theme.Typography.screenTitle)
                            .foregroundColor(Theme.Colors.textPrimary)
                            .accessibilityAddTraits(.isHeader)
                        
                        Text("Explore science-backed wellness practices")
                            .font(Theme.Typography.poppins(.regular, size: 14.5))
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                    .padding(.top, Theme.Spacing.headerTitleSpacing)
                    
                    // Topics Cards List
                    LazyVStack(spacing: 14) {
                        ForEach(topics) { topic in
                            let isCompleted = effectiveCompletedSlugs.contains(topic.slug)
                            EducationTopicCard(
                                topic: topic,
                                isCompleted: isCompleted,
                                action: {
                                    if let onSelectTopic = onSelectTopic {
                                        onSelectTopic(topic)
                                    } else {
                                        router?.navigate(to: .educationDetail(topic: topic))
                                    }
                                }
                            )
                            .overlay {
                                if appEnvironment?.draftStore.quiz(for: topic.slug) != nil {
                                    InProgressCardOverlay(title: "Quiz in progress", onContinue: {
                                        router?.navigate(to: .educationQuiz(topic: topic))
                                    }, onDiscard: {
                                        do {
                                            try appEnvironment?.draftStore.discardQuiz(for: topic.slug)
                                        } catch {
                                            draftError = "The quiz could not be discarded. Please try again."
                                        }
                                    })
                                }
                            }
                        }
                    }
                    .padding(.top, 2)
                    .padding(.bottom, 24)
                }
                .padding(.horizontal, 20)
            }
        }
        .careAppBackground()
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await loadProgress()
        }
        .alert("Could not update quiz", isPresented: Binding(get: { draftError != nil }, set: { if !$0 { draftError = nil } })) {
            Button("OK", role: .cancel) { draftError = nil }
        } message: { Text(draftError ?? "") }
    }
    
    private func loadProgress() async {
        guard let appEnvironment = appEnvironment else { return }
        if let map = try? await appEnvironment.educationRepo.fetchAllProgress() {
            persistedCompletedSlugs = Set(map.values.filter { $0.isCompleted }.map { $0.slug })
        }
    }
}

// MARK: - Previews
#Preview("Education Topics View") {
    EducationTopicsView()
        .environment(AppRouter())
}
