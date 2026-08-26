import SwiftUI

// MARK: - Expandable Accordion Card (Figma Frame 95:2 "Results by Individual")
public struct ExpandableAccordionCard: View {
    public let title: String
    public let scoreLabel: String
    public let tier: SafetyTier
    public let isExpanded: Bool
    public let onToggle: () -> Void
    
    public init(
        title: String,
        scoreLabel: String,
        tier: SafetyTier,
        isExpanded: Bool,
        onToggle: @escaping () -> Void
    ) {
        self.title = title
        self.scoreLabel = scoreLabel
        self.tier = tier
        self.isExpanded = isExpanded
        self.onToggle = onToggle
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            Button(action: onToggle) {
                HStack(spacing: 12) {
                    Text(title)
                        .font(Theme.Typography.cardTitle)
                        .foregroundColor(Theme.Colors.textPrimary)
                    
                    Spacer()
                    
                    Text(scoreLabel)
                        .font(Theme.Typography.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(tier.backgroundColor)
                        .foregroundColor(tier.tierColor)
                        .clipShape(Capsule())
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Theme.Colors.textSecondary)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isExpanded)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                VStack(spacing: 12) {
                    Divider()
                        .background(Theme.Colors.dividerSubtle)
                    
                    HStack(spacing: 16) {
                        HistoricalScoreColumn(date: "5/16", score: 31, tier: .highRisk)
                        HistoricalScoreColumn(date: "5/25", score: 59, tier: .moderate)
                        HistoricalScoreColumn(date: "5/29", score: 83, tier: .healthy)
                    }
                    .padding(.vertical, 8)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }
        }
        .background(Theme.Colors.cardSurface)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

// MARK: - Internal Historical Column Widget
struct HistoricalScoreColumn: View {
    let date: String
    let score: Int
    let tier: SafetyTier
    
    var body: some View {
        VStack(spacing: 4) {
            Text(date)
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
            
            Text("\(score)")
                .font(Theme.Typography.cardTitle)
                .foregroundColor(tier.tierColor)
            
            Text(tier.rawValue)
                .font(Theme.Typography.miniBadge)
                .foregroundColor(Theme.Colors.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Theme.Colors.background)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

// MARK: - Previews
#Preview("Expandable Historical Card") {
    struct PreviewWrapper: View {
        @State var expanded = true
        var body: some View {
            VStack(spacing: 16) {
                ExpandableAccordionCard(
                    title: "Sarah Mitchell",
                    scoreLabel: "83/100 Safe",
                    tier: .healthy,
                    isExpanded: expanded,
                    onToggle: { expanded.toggle() }
                )
            }
            .padding(20)
            .background(Theme.Colors.surfaceSecondary)
        }
    }
    return PreviewWrapper()
}
