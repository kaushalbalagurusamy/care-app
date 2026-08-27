import SwiftUI

// MARK: - Reusable "Bubble Card" Container (Figma Frames 11:4, 13:4, 29:4, 95:2)
public struct BubbleCardContainer<Content: View>: View {
    public let title: String?
    public let showInfoIcon: Bool
    public let onInfoTap: (() -> Void)?
    public let cornerRadius: CGFloat
    public let fill: Color
    public let content: () -> Content
    
    public init(
        title: String? = nil,
        showInfoIcon: Bool = false,
        onInfoTap: (() -> Void)? = nil,
        cornerRadius: CGFloat = 18.0,
        fill: Color = Theme.Colors.cardSurface,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.showInfoIcon = showInfoIcon
        self.onInfoTap = onInfoTap
        self.cornerRadius = cornerRadius
        self.fill = fill
        self.content = content
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let title = title {
                HStack(alignment: .center) {
                    Text(title)
                        .font(Theme.Typography.poppins(.bold, size: 18))
                        .foregroundColor(Theme.Colors.textPrimary)
                    
                    Spacer()
                    
                    if showInfoIcon {
                        Button(action: { onInfoTap?() }) {
                            Circle()
                                .stroke(Theme.Colors.primary, lineWidth: 1.5)
                                .frame(width: 20, height: 20)
                                .overlay(
                                    Text("i")
                                        .font(.system(size: 12, weight: .bold, design: .serif))
                                        .foregroundColor(Theme.Colors.primary)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            content()
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(fill)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(Theme.Colors.dividerSubtle, lineWidth: 1)
        )
    }
}

// MARK: - Previews
#Preview("Bubble Card Container") {
    VStack(spacing: 20) {
        BubbleCardContainer(title: "Relational Safety", showInfoIcon: true) {
            Text("Content inside the bubble envelope")
                .font(Theme.Typography.body)
        }
        
        BubbleCardContainer(title: nil, cornerRadius: 28.0) {
            Text("28pt radius large bubble envelope")
                .font(Theme.Typography.body)
        }
    }
    .padding(20)
    .background(Theme.Colors.background)
}
