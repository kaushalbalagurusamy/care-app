import SwiftUI

// MARK: - Modular Atomic App Icon System
public enum AppIcon {
    case home
    case chart
    case profile
    case back
    case info
    case checkmark
    case sparkle
    case prmLibrary
    case calendar
    case arrowRight
    case arrowLeft
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
        case .sparkle:
            Image(systemName: "sparkles")
                .font(.system(size: size, weight: weight))
                .foregroundColor(color)
        case .prmLibrary:
            PRMOpenBookShape()
                .stroke(color, style: StrokeStyle(lineWidth: size * 1.66667 / 19, lineCap: .round, lineJoin: .round))
                .frame(width: size, height: size)
        case .calendar:
            Image("icon_calendar")
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
                .foregroundColor(color)
        case .arrowRight:
            Image(systemName: "arrow.right")
                .font(.system(size: size, weight: weight))
                .foregroundColor(color)
        case .arrowLeft:
            Image(systemName: "arrow.left")
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
        case .sparkle: return "AppIcon_sparkle"
        case .prmLibrary: return "AppIcon_prmLibrary"
        case .calendar: return "AppIcon_calendar"
        case .arrowRight: return "AppIcon_arrowRight"
        case .arrowLeft: return "AppIcon_arrowLeft"
        case .custom(let name): return "AppIcon_\(name)"
        }
    }
    
    public var accessibilityLabel: String {
        switch self {
        case .home: return "Home"
        case .chart: return "Past Results"
        case .profile: return "Profile"
        case .back: return "Back"
        case .info: return "Information"
        case .checkmark: return "Completed"
        case .sparkle: return "Personalized Action Plan"
        case .prmLibrary: return "Positive Relational Moments Library"
        case .calendar: return "Calendar"
        case .arrowRight: return "Next"
        case .arrowLeft: return "Previous"
        case .custom(let name): return name.replacingOccurrences(of: ".", with: " ").capitalized
        }
    }
}

// The two strokes trace the open-book icon in the PRM library Figma header.
private struct PRMOpenBookShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let x = rect.width / 19
        let y = rect.height / 19
        path.move(to: CGPoint(x: 9.5 * x, y: 5.14583 * y))
        path.addCurve(to: CGPoint(x: 2.77083 * x, y: 3.16667 * y), control1: CGPoint(x: 7.67917 * x, y: 3.5625 * y), control2: CGPoint(x: 5.7 * x, y: 3.16667 * y))
        path.addLine(to: CGPoint(x: 2.77083 * x, y: 14.25 * y))
        path.addCurve(to: CGPoint(x: 9.5 * x, y: 16.2292 * y), control1: CGPoint(x: 5.7 * x, y: 14.25 * y), control2: CGPoint(x: 7.67917 * x, y: 14.6458 * y))
        path.addCurve(to: CGPoint(x: 16.2292 * x, y: 14.25 * y), control1: CGPoint(x: 11.3208 * x, y: 14.6458 * y), control2: CGPoint(x: 13.3 * x, y: 14.25 * y))
        path.addLine(to: CGPoint(x: 16.2292 * x, y: 3.16667 * y))
        path.addCurve(to: CGPoint(x: 9.5 * x, y: 5.14583 * y), control1: CGPoint(x: 13.3 * x, y: 3.16667 * y), control2: CGPoint(x: 11.3208 * x, y: 3.5625 * y))
        path.move(to: CGPoint(x: 9.5 * x, y: 5.14583 * y))
        path.addLine(to: CGPoint(x: 9.5 * x, y: 16.2292 * y))
        return path
    }
}

// MARK: - Reusable Calendar Icon Component
public struct CalendarIcon: View {
    public let size: CGFloat
    public let color: Color
    
    public init(size: CGFloat = 16, color: Color = Theme.Colors.primary) {
        self.size = size
        self.color = color
    }
    
    public var body: some View {
        AppIcon.calendar.view(size: size, color: color)
    }
}
