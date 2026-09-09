import SwiftUI

// MARK: - Reusable "Bubble Card" Container (Figma Frames 11:4, 13:4, 29:4, 95:2)
public struct BubbleCardContainer<Content: View>: View {
    public let title: String?
    public let isCollapsible: Bool
    public let showInfoIcon: Bool
    public let onInfoTap: (() -> Void)?
    public let cornerRadius: CGFloat
    public let fill: Color
    public let content: () -> Content
    
    @State private var isExpanded: Bool
    
    public init(
        title: String? = nil,
        isCollapsible: Bool = false,
        defaultExpanded: Bool = true,
        showInfoIcon: Bool = false,
        onInfoTap: (() -> Void)? = nil,
        cornerRadius: CGFloat = 18.0,
        fill: Color = Theme.Colors.cardSurface,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.isCollapsible = isCollapsible
        self.showInfoIcon = showInfoIcon
        self.onInfoTap = onInfoTap
        self.cornerRadius = cornerRadius
        self.fill = fill
        self.content = content
        self._isExpanded = State(initialValue: defaultExpanded)
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            if let title = title {
                if isCollapsible {
                    Button(action: {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            isExpanded.toggle()
                        }
                    }) {
                        HStack(alignment: .center) {
                            Text(title)
                                .font(Theme.Typography.poppins(.bold, size: 18))
                                .foregroundColor(Theme.Colors.textPrimary)
                            
                            Spacer()
                            
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(Theme.Colors.primary)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                } else {
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
            }
            
            if !isCollapsible || isExpanded {
                if isCollapsible && title != nil {
                    Divider()
                        .background(Theme.Colors.dividerSubtle)
                        .padding(.vertical, 2)
                }
                
                content()
            }
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
