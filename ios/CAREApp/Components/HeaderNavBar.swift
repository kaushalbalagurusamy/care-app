import SwiftUI

// MARK: - Sparkle Button Placement Option
public enum SparklePlacement {
    case left
    case right
}

// MARK: - Reusable High-Fidelity Header Navigation Bar (Figma Frames 5:4, 11:4, 13:4, 29:4, 41:4)
public struct HeaderNavBar: View {
    @Environment(AppRouter.self) private var router: AppRouter?
    @State private var isShowingStorageSettings: Bool = false
    
    public let showBackButton: Bool
    public let showHomeButton: Bool
    public let showSparkleButton: Bool
    public let sparklePlacement: SparklePlacement
    public let showChartButton: Bool
    public let showProfileButton: Bool
    public let title: String?
    public let onBack: (() -> Void)?
    public let onHome: (() -> Void)?
    public let onSparkle: (() -> Void)?
    public let onChart: (() -> Void)?
    public let onProfile: (() -> Void)?
    
    public init(
        showBackButton: Bool = true,
        showHomeButton: Bool = true,
        showSparkleButton: Bool = true,
        sparklePlacement: SparklePlacement = .right,
        showChartButton: Bool = true,
        showProfileButton: Bool = true,
        title: String? = nil,
        onBack: (() -> Void)? = nil,
        onHome: (() -> Void)? = nil,
        onSparkle: (() -> Void)? = nil,
        onChart: (() -> Void)? = nil,
        onProfile: (() -> Void)? = nil
    ) {
        self.showBackButton = showBackButton
        self.showHomeButton = showHomeButton
        self.showSparkleButton = showSparkleButton
        self.sparklePlacement = sparklePlacement
        self.showChartButton = showChartButton
        self.showProfileButton = showProfileButton
        self.title = title
        self.onBack = onBack
        self.onHome = onHome
        self.onSparkle = onSparkle
        self.onChart = onChart
        self.onProfile = onProfile
    }
    
    public var body: some View {
        HStack(alignment: .center) {
            // Left Button Cluster (Back, Home & Optional Sparkle)
            HStack(spacing: 8) {
                if showBackButton {
                    CircularNavIconButton(
                        icon: .back,
                        action: {
                            if let onBack = onBack {
                                onBack()
                            } else {
                                router?.pop()
                            }
                        }
                    )
                }
                
                if showHomeButton {
                    CircularNavIconButton(
                        icon: .home,
                        action: {
                            if let onHome = onHome {
                                onHome()
                            } else {
                                router?.popToRoot()
                            }
                        }
                    )
                }
                
                if showSparkleButton && sparklePlacement == .left {
                    CircularNavIconButton(
                        icon: .sparkle,
                        action: {
                            if let onSparkle = onSparkle {
                                onSparkle()
                            } else {
                                if router?.currentRoute != .personalizedActionPlan {
                                    router?.navigate(to: .personalizedActionPlan)
                                }
                            }
                        }
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
            
            // Right Button Cluster (Past Results Chart, Sparkle Action Plan & Profile)
            HStack(spacing: 8) {
                if showChartButton {
                    CircularNavIconButton(
                        icon: .chart,
                        action: {
                            if let onChart = onChart {
                                onChart()
                            } else {
                                if router?.currentRoute != .pastResults {
                                    router?.navigate(to: .pastResults)
                                }
                            }
                        }
                    )
                }
                
                if showSparkleButton && sparklePlacement == .right {
                    CircularNavIconButton(
                        icon: .sparkle,
                        action: {
                            if let onSparkle = onSparkle {
                                onSparkle()
                            } else {
                                if router?.currentRoute != .personalizedActionPlan {
                                    router?.navigate(to: .personalizedActionPlan)
                                }
                            }
                        }
                    )
                }
                
                if showProfileButton {
                    CircularNavIconButton(
                        icon: .profile,
                        action: {
                            if let onProfile = onProfile {
                                onProfile()
                            } else {
                                isShowingStorageSettings = true
                            }
                        }
                    )
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 3.3)
        .padding(.bottom, 3.3)
        .frame(height: 50.6)
        .padding(.top, -12)
        .background(
            Theme.Colors.background
                .ignoresSafeArea(edges: .top)
        )
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color(hex: "#E2E8F0").opacity(0.8))
                .frame(height: 0.5)
        }
        .sheet(isPresented: $isShowingStorageSettings) {
            StorageSettingsView()
        }
    }
}

// MARK: - 36x36 Standardized Circular Navigation Button
public struct CircularNavIconButton: View {
    public let icon: AppIcon
    public let action: () -> Void
    
    public init(icon: AppIcon, action: @escaping () -> Void) {
        self.icon = icon
        self.action = action
    }
    
    // Backwards compatibility initializer
    public init(iconName: String, isSystemImage: Bool = false, action: @escaping () -> Void) {
        if iconName.contains("home") {
            self.icon = .home
        } else if iconName.contains("chart") {
            self.icon = .chart
        } else if iconName.contains("profile") || iconName.contains("person") {
            self.icon = .profile
        } else if iconName.contains("chevron") || iconName.contains("back") {
            self.icon = .back
        } else {
            self.icon = .custom(systemName: iconName)
        }
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Circle()
                .fill(Theme.Colors.surfaceSecondary)
                .frame(width: 36, height: 36)
                .overlay(
                    icon.view(size: 15.5, weight: .semibold, color: Theme.Colors.primary)
                )
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .contentShape(Circle())
        .accessibilityIdentifier(icon.identifier)
        .accessibilityLabel(icon.accessibilityLabel)
        .accessibilityAddTraits(.isButton)
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
