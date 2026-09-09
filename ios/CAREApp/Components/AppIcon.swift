import SwiftUI

// MARK: - Modular Atomic App Icon System
public enum AppIcon {
    case home
    case chart
    case profile
    case back
    case info
    case checkmark
    case custom(systemName: String)
    
    @ViewBuilder
    public func view(size: CGFloat = 16, weight: Font.Weight = .semibold, color: Color = Theme.Colors.primary) -> some View {
        switch self {
        case .home:
            Image(systemName: "house.fill")
                .font(.system(size: size, weight: weight))
                .foregroundColor(color)
        case .chart:
            // Custom high-fidelity stats icon with refined bar geometry (33% wider)
            HStack(alignment: .bottom, spacing: max(1.8, size * 0.12)) {
                RoundedRectangle(cornerRadius: max(0.8, size * 0.06))
                    .fill(color)
                    .frame(width: max(2.9, size * 0.20), height: size * 0.42)
                RoundedRectangle(cornerRadius: max(0.8, size * 0.06))
                    .fill(color)
                    .frame(width: max(2.9, size * 0.20), height: size * 0.70)
                RoundedRectangle(cornerRadius: max(0.8, size * 0.06))
                    .fill(color)
                    .frame(width: max(2.9, size * 0.20), height: size * 0.98)
            }
            .frame(width: size, height: size, alignment: .bottom)
        case .profile:
            Image(systemName: "person.fill")
                .font(.system(size: size, weight: weight))
                .foregroundColor(color)
        case .back:
            Image(systemName: "chevron.left")
                .font(.system(size: size, weight: weight))
                .foregroundColor(color)
        case .info:
            Image(systemName: "info.circle")
                .font(.system(size: size, weight: weight))
                .foregroundColor(color)
        case .checkmark:
            Image(systemName: "checkmark")
                .font(.system(size: size, weight: weight))
                .foregroundColor(color)
        case .custom(let systemName):
            Image(systemName: systemName)
                .font(.system(size: size, weight: weight))
                .foregroundColor(color)
        }
    }
    
    public var identifier: String {
        switch self {
        case .home: return "AppIcon_home"
        case .chart: return "AppIcon_chart"
        case .profile: return "AppIcon_profile"
        case .back: return "AppIcon_back"
        case .info: return "AppIcon_info"
        case .checkmark: return "AppIcon_checkmark"
        case .custom(let name): return "AppIcon_\(name)"
        }
    }
    
    public var accessibilityLabel: String {
        switch self {
        case .home: return "Home"
        case .chart: return "Past Results"
        case .profile: return "Settings"
        case .back: return "Back"
        case .info: return "Information"
        case .checkmark: return "Completed"
        case .custom(let name): return name.replacingOccurrences(of: ".", with: " ").capitalized
        }
    }
}
