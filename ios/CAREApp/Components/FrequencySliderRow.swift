import SwiftUI

// MARK: - Interactive Frequency Slider Row (Figma Frame 41:4)
public struct FrequencySliderRow: View {
    public let initials: String
    public let name: String
    @Binding public var percentage: Double // 0.0 to 1.0
    
    public init(initials: String, name: String, percentage: Binding<Double>) {
        self.initials = initials
        self.name = name
        self._percentage = percentage
    }
    
    public var percentageString: String {
        return "\(Int(round(percentage * 100)))%"
    }
    
    public var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                // Initials avatar
                Circle()
                    .fill(Theme.Colors.primary.opacity(0.15))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Text(initials)
                            .font(Theme.Typography.subheadline)
                            .foregroundColor(Theme.Colors.primary)
                    )
                
                Text(name)
                    .font(Theme.Typography.cardTitle)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Spacer()
                
                // Percentage badge readout
                Text(percentageString)
                    .font(Theme.Typography.cardTitle)
                    .foregroundColor(Theme.Colors.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Theme.Colors.primary.opacity(0.1))
                    .clipShape(Capsule())
            }
            
            // Custom Slider Bar
            Slider(
                value: Binding(
                    get: { percentage },
                    set: { percentage = min(max($0, 0.0), 1.0) }
                ),
                in: 0.0...1.0,
                step: 0.01
            )
            .tint(Theme.Colors.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Theme.Colors.background)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Theme.Colors.dividerSubtle, lineWidth: 1)
        )
    }
}

// MARK: - Previews
#Preview("Frequency Sliders") {
    struct PreviewWrapper: View {
        @State var pct1: Double = 0.30
        @State var pct2: Double = 0.25
        
        var body: some View {
            VStack(spacing: 12) {
                FrequencySliderRow(initials: "SM", name: "Sarah Mitchell", percentage: $pct1)
                FrequencySliderRow(initials: "JC", name: "James Cooper", percentage: $pct2)
            }
            .padding(20)
            .background(Theme.Colors.surfaceSecondary)
        }
    }
    return PreviewWrapper()
}
