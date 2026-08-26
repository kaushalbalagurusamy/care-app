import SwiftUI

// MARK: - Selectable Relationship Contact Row (Figma Frame 17:4)
public struct RelationshipSelectionPill: View {
    public let initials: String
    public let name: String
    public let subtitle: String
    public let isSelected: Bool
    public let onToggle: () -> Void
    
    public init(
        initials: String,
        name: String,
        subtitle: String,
        isSelected: Bool,
        onToggle: @escaping () -> Void
    ) {
        self.initials = initials
        self.name = name
        self.subtitle = subtitle
        self.isSelected = isSelected
        self.onToggle = onToggle
    }
    
    public var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 16) {
                // Avatar Initials Badge
                Circle()
                    .fill(isSelected ? Theme.Colors.primary.opacity(0.2) : Theme.Colors.surfaceSecondary)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Text(initials)
                            .font(Theme.Typography.cardTitle)
                            .foregroundColor(isSelected ? Theme.Colors.primary : Theme.Colors.textSecondary)
                    )
                
                // Name and Description
                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(Theme.Typography.cardTitle)
                        .foregroundColor(Theme.Colors.textPrimary)
                    
                    Text(subtitle)
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                
                Spacer()
                
                // Selection Checkmark Circle
                ZStack {
                    Circle()
                        .stroke(isSelected ? Theme.Colors.primary : Theme.Colors.dividerMedium, lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(Theme.Colors.primary)
                            .frame(width: 24, height: 24)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(isSelected ? Theme.Colors.cardSurfaceSelected : Theme.Colors.background)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? Theme.Colors.primary : Theme.Colors.dividerSubtle, lineWidth: isSelected ? 1.5 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}
