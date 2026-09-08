import SwiftUI

// MARK: - Key Takeaways Card (Figma Frame 13 & Educational Sections)
public struct KeyTakeawaysCard: View {
    public let title: String
    public let points: [String]
    
    public init(
        title: String = "Key Takeaways",
        points: [String]
    ) {
        self.title = title
        self.points = points
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header with Sparkle Icon Badge
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Theme.Colors.primary.opacity(0.12))
                        .frame(width: 32, height: 32)
                    
                    if UIImage(named: "icon_sparkles") != nil {
                        Image("icon_sparkles")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .foregroundColor(Theme.Colors.primary)
                    } else {
                        Image(systemName: "sparkles")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Theme.Colors.primary)
                    }
                }
                
                Text(title)
                    .font(Theme.Typography.poppins(.bold, size: 17))
                    .foregroundColor(Theme.Colors.textPrimary)
            }
            
            // Bulleted Points List
            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(points.enumerated()), id: \.offset) { _, point in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Theme.Colors.primary)
                            .padding(.top, 2)
                        
                        Text(point)
                            .font(Theme.Typography.poppins(.regular, size: 14))
                            .foregroundColor(Theme.Colors.textPrimary)
                            .lineSpacing(3)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.Colors.cardSurface)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Theme.Colors.dividerSubtle, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(points.joined(separator: ". "))")
    }
}

// MARK: - Previews
#Preview("Key Takeaways Card") {
    KeyTakeawaysCard(
        title: "Key Takeaways",
        points: [
            "Human growth is fueled by authentic connection rather than autonomous isolation.",
            "The five good things of RCT provide a clinical blueprint for relational vitality.",
            "Mutual empathy rewires autonomic and neural circuits for lifelong resilience."
        ]
    )
    .padding(20)
    .background(Theme.Colors.background)
}
