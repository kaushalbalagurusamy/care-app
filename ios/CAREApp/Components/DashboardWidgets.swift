import SwiftUI

// MARK: - Dashboard Module Action Card (Figma Frame 5:4)
public struct ActionCardView: View {
    public let number: String
    public let title: String
    public let subtitle: String
    public let backgroundImageName: String?
    public let action: () -> Void
    
    public init(
        number: String,
        title: String,
        subtitle: String,
        backgroundImageName: String? = nil,
        action: @escaping () -> Void
    ) {
        self.number = number
        self.title = title
        self.subtitle = subtitle
        self.backgroundImageName = backgroundImageName
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            ZStack(alignment: .leading) {
                // Background Illustration
                if let bg = backgroundImageName {
                    Image(bg)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity, maxHeight: 96)
                        .clipped()
                }
                
                HStack(spacing: 16) {
                    // Number Pill
                    Text(number)
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.primary)
                        .frame(width: 32, height: 32)
                        .background(Theme.Colors.background)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(Theme.Typography.cardTitle)
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        Text(subtitle)
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Theme.Colors.primary)
                }
                .padding(.horizontal, 20)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 96)
            .background(Theme.Colors.cardSurface)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Theme.Colors.dividerSubtle, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Daily Streak Widget (Figma Frame 5:4)
public struct StreakBadgeView: View {
    public let daysCount: Int
    
    public init(daysCount: Int) {
        self.daysCount = daysCount
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            // Flame Icon Badge
            Circle()
                .fill(Theme.Colors.Safety.moderateRisk.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "flame.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Theme.Colors.Safety.moderateRisk)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Daily Streak: \(daysCount) Days Active")
                    .font(Theme.Typography.cardTitle)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Text("Consistent reflection builds stronger bonds")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Theme.Colors.background)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Theme.Colors.dividerSubtle, lineWidth: 1)
        )
    }
}

// MARK: - Previews
#Preview("Dashboard Widgets") {
    VStack(spacing: 16) {
        StreakBadgeView(daysCount: 5)
        ActionCardView(number: "01", title: "Education", subtitle: "Learn Wellness", backgroundImageName: "card_education_bg", action: {})
        ActionCardView(number: "02", title: "Assessment", subtitle: "Track Mind", backgroundImageName: "card_assessment_bg", action: {})
        ActionCardView(number: "03", title: "Exercises", subtitle: "Active Care", backgroundImageName: "card_exercises_bg", action: {})
    }
    .padding(20)
    .background(Theme.Colors.surfaceSecondary)
}
