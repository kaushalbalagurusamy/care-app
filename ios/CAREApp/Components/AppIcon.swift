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
            ZStack {
                PRMBookSpineFillShape().fill(color)
                PRMBookmarkFillShape().fill(color)
                PRMBookIconShape()
                    .stroke(color, style: StrokeStyle(lineWidth: size * 0.095, lineCap: .round, lineJoin: .round))
            }
            .frame(width: size * 1.2, height: size * 1.2)
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

// A single closed book with a bookmark, drawn for the 36-point header button.
private struct PRMBookIconShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let x = rect.width / 19
        let y = rect.height / 19
        func point(_ px: CGFloat, _ py: CGFloat) -> CGPoint { CGPoint(x: px * x, y: py * y) }

        // Cover, spine, and a short page edge.
        path.move(to: point(4.8, 2.5))
        path.addLine(to: point(15.5, 2.5))
        path.addQuadCurve(to: point(16.5, 3.5), control: point(16.5, 2.5))
        path.addLine(to: point(16.5, 16))
        path.addLine(to: point(5, 16))
        path.addQuadCurve(to: point(2.5, 13.5), control: point(2.5, 16))
        path.addLine(to: point(2.5, 4.8))
        path.addQuadCurve(to: point(4.8, 2.5), control: point(2.5, 2.5))
        path.move(to: point(5.3, 2.5))
        path.addLine(to: point(5.3, 16))
        path.move(to: point(5.3, 14.1))
        path.addLine(to: point(16.5, 14.1))

        // A single notched bookmark hangs from the top edge.
        path.move(to: point(11, 2.5))
        path.addLine(to: point(11, 8.2))
        path.addLine(to: point(12.5, 7.1))
        path.addLine(to: point(14, 8.2))
        path.addLine(to: point(14, 2.5))
        return path
    }
}

private struct PRMBookSpineFillShape: Shape {
    func path(in rect: CGRect) -> Path {
        let x = rect.width / 19
        let y = rect.height / 19
        var path = Path()
        path.move(to: CGPoint(x: 4.8 * x, y: 2.5 * y))
        path.addLine(to: CGPoint(x: 5.3 * x, y: 2.5 * y))
        path.addLine(to: CGPoint(x: 5.3 * x, y: 16 * y))
        path.addQuadCurve(to: CGPoint(x: 2.5 * x, y: 13.5 * y), control: CGPoint(x: 2.5 * x, y: 16 * y))
        path.addLine(to: CGPoint(x: 2.5 * x, y: 4.8 * y))
        path.addQuadCurve(to: CGPoint(x: 4.8 * x, y: 2.5 * y), control: CGPoint(x: 2.5 * x, y: 2.5 * y))
        path.closeSubpath()
        return path
    }
}

private struct PRMBookmarkFillShape: Shape {
    func path(in rect: CGRect) -> Path {
        let x = rect.width / 19
        let y = rect.height / 19
        var path = Path()
        path.move(to: CGPoint(x: 11 * x, y: 2.5 * y))
        path.addLine(to: CGPoint(x: 14 * x, y: 2.5 * y))
        path.addLine(to: CGPoint(x: 14 * x, y: 8.2 * y))
        path.addLine(to: CGPoint(x: 12.5 * x, y: 7.1 * y))
        path.addLine(to: CGPoint(x: 11 * x, y: 8.2 * y))
        path.closeSubpath()
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
