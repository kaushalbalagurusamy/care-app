import SwiftUI

// MARK: - Individual Contact Result Card (Figma Frame 29:4 "Results by Individual")
public struct IndividualResultCard: View {
    public let result: IndividualResult
    
    public init(result: IndividualResult) {
        self.result = result
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            // Initials Avatar Circle
            Circle()
                .fill(Theme.Colors.primary.opacity(0.15))
                .frame(width: 44, height: 44)
                .overlay(
                    Text(result.participant.person.initials)
                        .font(Theme.Typography.cardTitle)
                        .foregroundColor(Theme.Colors.primary)
                )
            
            // Name & Details
            VStack(alignment: .leading, spacing: 2) {
                Text(result.participant.person.name)
                    .font(Theme.Typography.cardTitle)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Text("\(result.participant.person.category.rawValue), \(result.participant.person.age)")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            
            Spacer()
            
            // Score & Safety Tier Badge
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int(result.normalizedScore))/100")
                    .font(Theme.Typography.cardTitle)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Text(result.safetyTier.rawValue)
                    .font(Theme.Typography.miniBadge)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(result.safetyTier.backgroundColor)
                    .foregroundColor(result.safetyTier.tierColor)
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(width: 310, height: 78)
        .background(Theme.Colors.cardSurface)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
