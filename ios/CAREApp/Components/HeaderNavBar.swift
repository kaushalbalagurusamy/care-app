import SwiftUI

// MARK: - Reusable High-Fidelity Header Navigation Bar (Figma Frames 5:4, 11:4, 13:4, 29:4, 41:4)
public struct HeaderNavBar: View {
    public let showBackButton: Bool
    public let showHomeButton: Bool
    public let showChartButton: Bool
    public let showProfileButton: Bool
    public let title: String?
    public let onBack: (() -> Void)?
    public let onHome: (() -> Void)?
    public let onChart: (() -> Void)?
    public let onProfile: (() -> Void)?
    
    public init(
        showBackButton: Bool = true,
        showHomeButton: Bool = true,
        showChartButton: Bool = true,
        showProfileButton: Bool = true,
        title: String? = nil,
        onBack: (() -> Void)? = nil,
        onHome: (() -> Void)? = nil,
        onChart: (() -> Void)? = nil,
        onProfile: (() -> Void)? = nil
    ) {
        self.showBackButton = showBackButton
        self.showHomeButton = showHomeButton
        self.showChartButton = showChartButton
        self.showProfileButton = showProfileButton
        self.title = title
        self.onBack = onBack
        self.onHome = onHome
        self.onChart = onChart
        self.onProfile = onProfile
    }
    
    public var body: some View {
        HStack(alignment: .center) {
            // Left Button Cluster (Back & Home)
            HStack(spacing: 8) {
                if showBackButton {
                    CircularNavIconButton(
                        icon: "chevron.left",
                        action: { onBack?() }
                    )
                }
                
                if showHomeButton {
                    CircularNavIconButton(
                        icon: "house.fill",
                        action: { onHome?() }
                    )
                }
            }
            
            Spacer()
            
            // Optional Center Title
            if let title = title {
                Text(title)
                    .font(Theme.Typography.headline)
                    .foregroundColor(Theme.Colors.textPrimary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Right Button Cluster (Past Results Chart & Profile)
            HStack(spacing: 8) {
                if showChartButton {
                    CircularNavIconButton(
                        icon: "chart.bar.fill",
                        action: { onChart?() }
                    )
                }
                
                if showProfileButton {
                    CircularNavIconButton(
                        icon: "person.fill",
                        action: { onProfile?() }
                    )
                }
            }
        }
        .padding(.horizontal, 20)
        .frame(height: 64)
        .background(Theme.Colors.background)
    }
}

// MARK: - 36x36 Circular Navigation Button (Figma Node 11:7, 5:12, 76:4, 76:7)
public struct CircularNavIconButton: View {
    public let icon: String
    public let action: () -> Void
    
    public init(icon: String, action: @escaping () -> Void) {
        self.icon = icon
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Circle()
                .fill(Theme.Colors.surfaceSecondary)
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Theme.Colors.primary)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Previews
#Preview("Header Navigation Variants") {
    VStack(spacing: 20) {
        // Full 4-button header
        HeaderNavBar(
            showBackButton: true,
            showHomeButton: true,
            showChartButton: true,
            showProfileButton: true
        )
        
        // Homepage header (No back button)
        HeaderNavBar(
            showBackButton: false,
            showHomeButton: true,
            showChartButton: true,
            showProfileButton: true,
            title: "C.A.R.E."
        )
    }
    .background(Theme.Colors.surfaceSecondary)
}
