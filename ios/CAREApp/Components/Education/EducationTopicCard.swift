import SwiftUI

// MARK: - Education Topic Card (Figma Frame 11: 122:4 / Node 122:33)
public struct EducationTopicCard: View {
    public let topic: EducationTopic
    public let isCompleted: Bool
    public let action: () -> Void
    
    public var minTouchTargetHeight: CGFloat { 72.0 }
    
    public init(
        topic: EducationTopic,
        isCompleted: Bool = false,
        action: @escaping () -> Void
    ) {
        self.topic = topic
        self.isCompleted = isCompleted
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            action()
        }) {
            HStack(spacing: 14) {
                // Leading Circular Icon Badge
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 48, height: 48)
                        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                    
                    if UIImage(named: topic.iconAsset) != nil {
                        Image(topic.iconAsset)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 26, height: 26)
                            .foregroundColor(Theme.Colors.primary)
                    } else {
                        Image(systemName: "book.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Theme.Colors.primary)
                    }
                }
                .frame(width: 48, height: 48)
                
                // Title and Subtitle Text Content
                VStack(alignment: .leading, spacing: 3) {
                    Text(topic.title)
                        .font(Theme.Typography.poppins(.bold, size: 16.5))
                        .foregroundColor(Theme.Colors.textPrimary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Text(topic.subtitle)
                        .font(Theme.Typography.poppins(.regular, size: 13.5))
                        .foregroundColor(Theme.Colors.textSecondary)
                        .lineSpacing(2)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Trailing Status and Navigation Chevron
                HStack(spacing: 6) {
                    if isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Theme.Colors.Safety.lowRisk)
                    }
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Theme.Colors.primary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(minHeight: minTouchTargetHeight)
            .background(Theme.Colors.cardSurface)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Theme.Colors.dividerSubtle, lineWidth: 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(topic.title), \(topic.subtitle), \(topic.estimatedReadMinutes) minute read\(isCompleted ? ", Completed" : "")")
        .accessibilityHint("Double tap to open lesson")
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Previews
#Preview("Education Topic Cards Matrix") {
    VStack(spacing: 14) {
        EducationTopicCard(
            topic: EducationTopic(
                id: "topic-1",
                slug: .relationalCulturalTheory,
                title: "Relational-Cultural Theory",
                subtitle: "Understanding how growth-fostering relationships heal.",
                iconAsset: "icon_rct_book",
                estimatedReadMinutes: 5,
                sections: [],
                quiz: QuizQuestion(
                    id: "quiz-1",
                    prompt: "Sample",
                    options: [],
                    correctOptionLetter: "A",
                    rationale: ""
                )
            ),
            isCompleted: true,
            action: {}
        )
        
        EducationTopicCard(
            topic: EducationTopic(
                id: "topic-2",
                slug: .relationalNeuroscience,
                title: "Relational Neuroscience",
                subtitle: "How our brains are hardwired for social connection.",
                iconAsset: "icon_relational_neuroscience",
                estimatedReadMinutes: 6,
                sections: [],
                quiz: QuizQuestion(
                    id: "quiz-2",
                    prompt: "Sample",
                    options: [],
                    correctOptionLetter: "B",
                    rationale: ""
                )
            ),
            isCompleted: false,
            action: {}
        )
    }
    .padding(20)
    .background(Theme.Colors.background)
}
