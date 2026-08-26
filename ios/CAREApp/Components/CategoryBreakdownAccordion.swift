import SwiftUI

// MARK: - Category Breakdown Domain Item
public struct DomainBreakdownItem: Identifiable, Hashable, Equatable {
    public let id: UUID
    public let domain: CAREDomain
    public let score: Int
    public let maxScore: Int
    public let subtitleTitle: String
    public let explanation: String
    public let vagalToneTitle: String
    public let vagalToneExplanation: String
    
    public init(
        domain: CAREDomain,
        score: Int,
        maxScore: Int = 125,
        subtitleTitle: String,
        explanation: String,
        vagalToneTitle: String,
        vagalToneExplanation: String
    ) {
        self.id = UUID()
        self.domain = domain
        self.score = score
        self.maxScore = maxScore
        self.subtitleTitle = subtitleTitle
        self.explanation = explanation
        self.vagalToneTitle = vagalToneTitle
        self.vagalToneExplanation = vagalToneExplanation
    }
}

// MARK: - Category Breakdown Accordion View (Figma Frame 29:4 "Category Breakdown")
public struct CategoryBreakdownAccordion: View {
    public let items: [DomainBreakdownItem]
    @State private var expandedDomain: CAREDomain? = .calm
    
    public init(items: [DomainBreakdownItem]) {
        self.items = items
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            ForEach(items, id: \.id) { (item: DomainBreakdownItem) in
                let isExpanded = (expandedDomain == item.domain)
                
                VStack(spacing: 0) {
                    // Row Header Button
                    Button(action: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            if expandedDomain == item.domain {
                                expandedDomain = nil
                            } else {
                                expandedDomain = item.domain
                            }
                        }
                    }) {
                        HStack(spacing: 12) {
                            // Category Color Dot
                            Circle()
                                .fill(item.domain.themeColor)
                                .frame(width: 12, height: 12)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.domain.title)
                                    .font(Theme.Typography.cardTitle)
                                    .foregroundColor(Theme.Colors.textPrimary)
                                
                                Text("\(item.score)/\(item.maxScore)")
                                    .font(Theme.Typography.caption)
                                    .foregroundColor(Theme.Colors.textSecondary)
                            }
                            
                            Spacer()
                            
                            // Blue Triangle Expander (Figma Node 76:18)
                            Image(systemName: isExpanded ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill")
                                .font(.system(size: 11))
                                .foregroundColor(Theme.Colors.primary)
                        }
                        .padding(.vertical, 14)
                    }
                    .buttonStyle(.plain)
                    
                    // Expanded Body
                    if isExpanded {
                        VStack(alignment: .leading, spacing: 12) {
                            Divider()
                                .background(Theme.Colors.dividerSubtle)
                            
                            Text(item.subtitleTitle)
                                .font(Theme.Typography.cardTitle)
                                .foregroundColor(Theme.Colors.textPrimary)
                            
                            Text(item.explanation)
                                .font(Theme.Typography.body)
                                .foregroundColor(Theme.Colors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            // Vagal Tone Row with Info Icon
                            HStack {
                                Text(item.vagalToneTitle)
                                    .font(Theme.Typography.cardTitle)
                                    .foregroundColor(Theme.Colors.textPrimary)
                                
                                Spacer()
                                
                                Circle()
                                    .stroke(Theme.Colors.primary, lineWidth: 1.5)
                                    .frame(width: 16, height: 16)
                                    .overlay(
                                        Text("i")
                                            .font(.system(size: 10, weight: .bold, design: .serif))
                                            .foregroundColor(Theme.Colors.primary)
                                    )
                            }
                            .padding(.top, 4)
                            
                            Text(item.vagalToneExplanation)
                                .font(Theme.Typography.body)
                                .foregroundColor(Theme.Colors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.bottom, 16)
                    }
                    
                    if item.id != items.last?.id {
                        Divider()
                            .background(Theme.Colors.dividerSubtle)
                    }
                }
            }
        }
    }
}

// MARK: - Previews
#Preview("Category Breakdown Accordion") {
    let sampleItems = [
        DomainBreakdownItem(
            domain: .calm,
            score: 18,
            maxScore: 125,
            subtitleTitle: "C is for Calm",
            explanation: "Calmness is related to the functioning of the smart vagus nerve and your social engagement system. When these systems are healthy, they help you to modulate stress levels.",
            vagalToneTitle: "Good Vagal Tone",
            vagalToneExplanation: "Your smart vagus nerve helps calm and relax you. Your relationships help you manage the stress of day-to-day life."
        ),
        DomainBreakdownItem(
            domain: .accepted,
            score: 20,
            maxScore: 125,
            subtitleTitle: "A is for Accepted",
            explanation: "Acceptance reflects feelings of belonging, safety, and mutual respect in your relational network.",
            vagalToneTitle: "Belonging Signaling",
            vagalToneExplanation: "Neural safety pathways activate when you feel recognized and accepted by your peers."
        ),
        DomainBreakdownItem(
            domain: .resonant,
            score: 15,
            maxScore: 125,
            subtitleTitle: "R is for Resonant",
            explanation: "Resonance captures emotional attunement and mutual empathy.",
            vagalToneTitle: "Co-Regulation Capacity",
            vagalToneExplanation: "Co-regulation allows physiological calming through shared social connection."
        ),
        DomainBreakdownItem(
            domain: .energetic,
            score: 22,
            maxScore: 125,
            subtitleTitle: "E is for Energetic",
            explanation: "Energy describes the vitality, motivation, and positive arousal derived from social bonds.",
            vagalToneTitle: "Autonomic Vitality",
            vagalToneExplanation: "Healthy relationships stimulate autonomic resilience and energized focus."
        )
    ]
    
    BubbleCardContainer(title: "Category Breakdown") {
        CategoryBreakdownAccordion(items: sampleItems)
    }
    .padding(20)
    .background(Theme.Colors.background)
}
