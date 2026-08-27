import SwiftUI

// MARK: - Standard Primary Action Button (Figma Frame 11:4, 13:4, 17:4, 25:4, 29:4)
public struct PrimaryButton: View {
    public let title: String
    public let icon: String?
    public let appIcon: AppIcon?
    public let isEnabled: Bool
    public let isLoading: Bool
    public let action: () -> Void
    
    public var minHeight: CGFloat { 56.0 }
    
    public init(
        title: String,
        icon: String? = nil,
        appIcon: AppIcon? = nil,
        isEnabled: Bool = true,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.appIcon = appIcon
        self.isEnabled = isEnabled
        self.isLoading = isLoading
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            if isEnabled && !isLoading {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                action()
            }
        }) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    if let appIcon = appIcon {
                        appIcon.view(size: 16, weight: .semibold, color: .white)
                    } else if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .semibold))
                    }
                    Text(title)
                        .font(Theme.Typography.cardTitle)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .foregroundColor(.white)
            .background(isEnabled ? Theme.Colors.primary : Theme.Colors.textMuted)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .disabled(!isEnabled || isLoading)
        .buttonStyle(.plain)
        .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

// MARK: - Secondary Outlined Button (Figma Frame 29:4 "Return to Home")
public struct SecondaryButton: View {
    public let title: String
    public let icon: String?
    public let appIcon: AppIcon?
    public let action: () -> Void
    
    public var minHeight: CGFloat { 56.0 }
    
    public init(
        title: String,
        icon: String? = nil,
        appIcon: AppIcon? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.appIcon = appIcon
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            action()
        }) {
            HStack(spacing: 8) {
                if let appIcon = appIcon {
                    appIcon.view(size: 16, weight: .semibold, color: Theme.Colors.primary)
                } else if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(title)
                    .font(Theme.Typography.cardTitle)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .foregroundColor(Theme.Colors.primary)
            .background(Theme.Colors.background)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Theme.Colors.dividerMedium, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

// MARK: - Previews
#Preview("Action Buttons Matrix") {
    VStack(spacing: 16) {
        PrimaryButton(title: "Begin the Survey", icon: "arrow.right", action: {})
        PrimaryButton(title: "Next: James Cooper", action: {})
        PrimaryButton(title: "Loading...", isLoading: true, action: {})
        PrimaryButton(title: "Disabled Continue", isEnabled: false, action: {})
        SecondaryButton(title: "Return to Home", icon: "house.fill", action: {})
    }
    .padding(20)
    .background(Theme.Colors.surfaceSecondary)
}
