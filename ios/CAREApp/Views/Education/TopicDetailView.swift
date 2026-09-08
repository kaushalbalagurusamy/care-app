import SwiftUI

// MARK: - Topic Detail View (Figma Frames 12–17: Polymorphic Template)
public struct TopicDetailView: View {
    @Environment(AppRouter.self) private var router: AppRouter?
    
    public let topic: EducationTopic
    public let onTakeQuiz: (() -> Void)?
    public let onBack: (() -> Void)?
    public let onHome: (() -> Void)?
    
    public init(
        topic: EducationTopic,
        onTakeQuiz: (() -> Void)? = nil,
        onBack: (() -> Void)? = nil,
        onHome: (() -> Void)? = nil
    ) {
        self.topic = topic
        self.onTakeQuiz = onTakeQuiz
        self.onBack = onBack
        self.onHome = onHome
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Standardized Top Navigation Bar (reused app-wide)
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
                    
                    // Main Lesson Title (Matching Figma Page 2 Frame titles)
                    Text(topic.title)
                        .font(Theme.Typography.poppins(.bold, size: 26))
                        .foregroundColor(Theme.Colors.textPrimary)
                        .lineSpacing(2)
                        .padding(.top, 4)
                        .accessibilityAddTraits(.isHeader)
                    
                    // Polymorphic Section Content
                    ForEach(Array(topic.sections.enumerated()), id: \.offset) { _, section in
                        sectionView(for: section)
                    }
                    
                    // Bottom Action: Test Your Understanding Primary CTA
                    PrimaryButton(
                        title: "Test Your Understanding",
                        icon: "arrow.right",
                        action: {
                            if let onTakeQuiz = onTakeQuiz {
                                onTakeQuiz()
                            } else {
                                router?.navigate(to: .educationQuiz(topic: topic))
                            }
                        }
                    )
                    .padding(.top, 8)
                    .padding(.bottom, 28)
                }
                .padding(.horizontal, 20)
            }
        }
        .careAppBackground()
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
    
    // MARK: - Section Payload Renderer
    @ViewBuilder
    private func sectionView(for section: EducationSectionPayload) -> some View {
        switch section {
        case .textOverview(let heading, let body):
            BubbleCardContainer(title: heading.isEmpty ? nil : heading) {
                Text(body)
                    .font(Theme.Typography.poppins(.regular, size: 14.5))
                    .foregroundColor(Theme.Colors.textSecondary)
                    .lineSpacing(3.5)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
        case .foundersGrid(let founders):
            BubbleCardContainer(title: "Founders") {
                VStack(spacing: 16) {
                    ForEach(founders) { founder in
                        FounderCard(
                            founder: founder,
                            showDivider: founder.id != founders.last?.id
                        )
                    }
                }
            }
            
        case .fiveGoodThings(let items):
            BubbleCardContainer(title: "5 Good Things") {
                VStack(spacing: 14) {
                    ForEach(items) { item in
                        FiveGoodThingsCard(item: item)
                    }
                }
            }
            
        case .neuralPathwayMapping(let pathways):
            VStack(spacing: 14) {
                ForEach(pathways) { pathway in
                    NeurobiologyPathwayCard(pathway: pathway)
                }
            }
            
        case .illustrationParagraph(let imageAsset, let body):
            VStack(alignment: .center, spacing: 16) {
                if UIImage(named: imageAsset) != nil {
                    Image(imageAsset)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                
                Text(body)
                    .font(Theme.Typography.poppins(.regular, size: 14.5))
                    .foregroundColor(Theme.Colors.textSecondary)
                    .lineSpacing(3.5)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(18)
            .background(Theme.Colors.cardSurface)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Theme.Colors.dividerSubtle, lineWidth: 1)
            )
            
        case .keyTakeaways(let points):
            KeyTakeawaysCard(points: points)
        }
    }
}

// MARK: - Previews
#Preview("Topic Detail View — RCT") {
    if let manifest = try? EducationManifestLoader.loadBundledManifest(),
       let rct = manifest.first(where: { $0.slug == .relationalCulturalTheory }) {
        TopicDetailView(topic: rct)
            .environment(AppRouter())
    } else {
        Text("Manifest not loaded")
    }
}
