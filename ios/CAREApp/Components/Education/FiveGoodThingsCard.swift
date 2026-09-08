import SwiftUI

// MARK: - Five Good Things Card (Figma Frame 13: 156:4 / Node 164:3)
public struct FiveGoodThingsCard: View {
    public let item: FiveGoodThingsItem
    public let defaultExpanded: Bool
    @State private var isExpanded: Bool
    
    public var badgeText: String {
        "\(item.index)"
    }
    
    public var accentColor: Color {
        switch item.index {
        case 1: return Color(hex: "#F59E0B") // Zest (Amber)
        case 2: return Color(hex: "#EF4444") // Sense of Worth (Coral)
        case 3: return Color(hex: "#8B5CF6") // Clarity (Purple)
        case 4: return Color(hex: "#10B981") // Creativity (Emerald)
        case 5: return Color(hex: "#0EA5E9") // Connection (Sky Blue)
        default: return Theme.Colors.primary
        }
    }
    
    public init(item: FiveGoodThingsItem, defaultExpanded: Bool = true) {
        self.item = item
        self.defaultExpanded = defaultExpanded
        self._isExpanded = State(initialValue: defaultExpanded)
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header Row (Number badge, title, disclosure triangle)
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 12) {
                    // Numbered Circular Badge (1..5)
                    ZStack {
                        Circle()
                            .fill(accentColor)
                            .frame(width: 24, height: 24)
                        
                        Text(badgeText)
                            .font(Theme.Typography.poppins(.bold, size: 12))
                            .foregroundColor(.white)
                    }
                    .frame(width: 24, height: 24)
                    
                    Text(item.title)
                        .font(Theme.Typography.poppins(.bold, size: 16))
                        .foregroundColor(Theme.Colors.textPrimary)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill")
                        .font(.system(size: 10))
                        .foregroundColor(Theme.Colors.primary)
                }
                .frame(minHeight: Theme.Dimensions.minTouchTarget)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            // Expanded Neurobiological Explanation
            if isExpanded {
                Text(item.neuroDescription)
                    .font(Theme.Typography.poppins(.regular, size: 13.5))
                    .foregroundColor(Theme.Colors.textSecondary)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.leading, 36)
                    .padding(.bottom, 6)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Good Thing \(item.index): \(item.title). \(item.neuroDescription)")
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Previews
#Preview("Five Good Things Matrix") {
    VStack(spacing: 12) {
        FiveGoodThingsCard(
            item: FiveGoodThingsItem(
                id: "fgt-1",
                index: 1,
                title: "Zest",
                neuroDescription: "Zest is the surge of emotional energy, vitality, and enthusiasm that spontaneously arises when we feel genuinely seen."
            )
        )
        
        FiveGoodThingsCard(
            item: FiveGoodThingsItem(
                id: "fgt-2",
                index: 2,
                title: "Sense of Worth",
                neuroDescription: "Sense of worth is the deep realization that one is valued, respected, and worthy of care."
            )
        )
    }
    .padding(20)
    .background(Theme.Colors.background)
}
