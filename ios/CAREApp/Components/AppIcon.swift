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
            Image(systemName: "chart.bar.fill")
                .font(.system(size: size, weight: weight))
                .foregroundColor(color)
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
}
