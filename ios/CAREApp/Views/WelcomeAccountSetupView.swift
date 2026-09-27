import SwiftUI

// MARK: - Screen 19: Welcome & Account Setup View (Figma Frame 213:4)
public struct WelcomeAccountSetupView: View {
    public let router: AppRouter
    
    @State private var fullName: String = ""
    @State private var age: String = ""
    @State private var selectedFrequency: String = "biweekly"
    
    let frequencies = [
        ("2x/week", false),
        ("1x/week", false),
        ("biweekly", true),
        ("monthly", false),
        ("every 3 months", false)
    ]
    
    public init(router: AppRouter) {
        self.router = router
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            HeaderNavBar(
                showBackButton: true,
                showHomeButton: true,
                showSparkleButton: true,
                sparklePlacement: .right,
                title: nil
            )
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Title & Subtitle Header
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Welcome")
                            .font(Theme.Typography.poppins(.bold, size: 30))
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        Text("Let's finish setting up your account to start evaluating and tracking your relational health.")
                            .font(Theme.Typography.poppins(.regular, size: 15))
                            .foregroundColor(Theme.Colors.textSecondary)
                            .lineSpacing(3)
                    }
                    .padding(.top, Theme.Spacing.headerTitleSpacing)
                    
                    // Profile Photo Placeholder
                    VStack(spacing: 8) {
                        Circle()
                            .strokeBorder(Theme.Colors.primary.opacity(0.4), style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(Theme.Colors.primary)
                            )
                        
                        Text("Add Profile Photo")
                            .font(Theme.Typography.poppins(.medium, size: 13))
                            .foregroundColor(Theme.Colors.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    
                    // Form Fields
                    VStack(alignment: .leading, spacing: 14) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Full Name")
                                .font(Theme.Typography.poppins(.semiBold, size: 14))
                                .foregroundColor(Theme.Colors.textPrimary)
                            
                            TextField("e.g., Alex Johnson", text: $fullName)
                                .font(Theme.Typography.poppins(.regular, size: 15))
                                .padding(.horizontal, 14)
                                .frame(height: 48)
                                .background(Theme.Colors.surfaceSecondary)
                                .cornerRadius(12)
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Age")
                                .font(Theme.Typography.poppins(.semiBold, size: 14))
                                .foregroundColor(Theme.Colors.textPrimary)
                            
                            TextField("e.g., 28", text: $age)
                                .font(Theme.Typography.poppins(.regular, size: 15))
                                .keyboardType(.numberPad)
                                .padding(.horizontal, 14)
                                .frame(height: 48)
                                .background(Theme.Colors.surfaceSecondary)
                                .cornerRadius(12)
                        }
                    }
                    
                    // Assessment Frequency
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Target Assessment Frequency")
                            .font(Theme.Typography.poppins(.semiBold, size: 14))
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        FlowLayout(spacing: 8) {
                            ForEach(frequencies, id: \.0) { freq, isRecommended in
                                Button(action: {
                                    selectedFrequency = freq
                                }) {
                                    HStack(spacing: 4) {
                                        Text(freq)
                                            .font(Theme.Typography.poppins(.medium, size: 13))
                                        
                                        if isRecommended {
                                            Text("RECOMMENDED")
                                                .font(Theme.Typography.poppins(.bold, size: 9))
                                                .padding(.horizontal, 5)
                                                .padding(.vertical, 2)
                                                .background(Theme.Colors.primary.opacity(0.15))
                                                .clipShape(Capsule())
                                        }
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .foregroundColor(selectedFrequency == freq ? .white : Theme.Colors.textPrimary)
                                    .background(selectedFrequency == freq ? Theme.Colors.primary : Theme.Colors.cardSurface)
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule()
                                            .stroke(selectedFrequency == freq ? Theme.Colors.primary : Theme.Colors.dividerSubtle, lineWidth: 1)
                                    )
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            
            // Bottom Action
            VStack(spacing: 0) {
                Divider()
                    .background(Theme.Colors.dividerSubtle)
                
                Button(action: {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    router.popToRoot()
                }) {
                    Text("Complete Setup")
                        .font(Theme.Typography.buttonLabel)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Theme.Colors.primary)
                        .cornerRadius(28)
                }
                .padding(.horizontal, 20)
                .padding(.top, 14)
                .padding(.bottom, 10)
                .accessibilityIdentifier("CompleteSetupButton")
            }
            .background(Theme.Colors.background)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background.ignoresSafeArea())
    }
}

// MARK: - FlowLayout Helper
private struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        var height: CGFloat = 0
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > width && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }
        height = y + rowHeight
        return CGSize(width: width, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX && x > bounds.minX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }
    }
}

// MARK: - Previews
#Preview("Welcome Account Setup View") {
    WelcomeAccountSetupView(router: AppRouter())
}
