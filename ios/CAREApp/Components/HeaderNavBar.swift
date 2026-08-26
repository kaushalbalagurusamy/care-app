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
                        iconName: "chevron.left",
                        isSystemImage: true,
                        action: { onBack?() }
                    )
                }
                
                if showHomeButton {
                    if showBackButton {
                        CircularNavIconButton(
                            iconName: "icon_home",
                            isSystemImage: false,
                            action: { onHome?() }
                        )
                    } else {
                        // Figma Frame 5:12 Home Capsule Pill with Poppins typography
                        Button(action: { onHome?() }) {
                            HStack(spacing: 6) {
                                Image("icon_home")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 14, height: 14)
                                
                                Text("Home")
                                    .font(Theme.Typography.menuLabel)
                                    .foregroundColor(Theme.Colors.primary)
                            }
                            .padding(.horizontal, 14)
                            .frame(height: 36)
                            .background(Theme.Colors.surfaceSecondary)
                            .clipShape(Capsule())
                            .contentShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
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
                        iconName: "icon_chart",
                        isSystemImage: false,
                        action: { onChart?() }
                    )
                }
                
                if showProfileButton {
                    CircularNavIconButton(
                        iconName: "icon_profile",
                        isSystemImage: false,
                        action: { onProfile?() }
                    )
                }
            }
        }
        .padding(.horizontal, 20)
        .frame(height: 52)
        .background(Theme.Colors.background)
    }
}

// MARK: - 36x36 Circular Navigation Button (Figma Node 11:7, 5:12, 76:4, 76:7)
public struct CircularNavIconButton: View {
    public let iconName: String
    public let isSystemImage: Bool
    public let action: () -> Void
    
    public init(iconName: String, isSystemImage: Bool = false, action: @escaping () -> Void) {
        self.iconName = iconName
        self.isSystemImage = isSystemImage
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Circle()
                .fill(Theme.Colors.surfaceSecondary)
                .frame(width: 36, height: 36)
                .overlay(
                    Group {
                        if isSystemImage {
                            Image(systemName: iconName)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Theme.Colors.primary)
                        } else {
                            Image(iconName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 18, height: 18)
                        }
                    }
                )
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .contentShape(Circle())
    }
}

// MARK: - Previews
#Preview("Header Navigation Variants") {
    VStack(spacing: 20) {
        HeaderNavBar(showBackButton: true, showHomeButton: true, showChartButton: true, showProfileButton: true)
        HeaderNavBar(showBackButton: false, showHomeButton: true, showChartButton: true, showProfileButton: true)
    }
    .background(Theme.Colors.surfaceSecondary)
}
