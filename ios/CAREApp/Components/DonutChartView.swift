import SwiftUI

// MARK: - Donut Segment Model
public struct DonutSegment: Identifiable, Hashable {
    public let id = UUID()
    public let title: String
    public let color: Color
    public let percentage: Double // 0.0 to 1.0 (e.g. 0.21 = 21%)
    
    public init(title: String = "", color: Color, percentage: Double) {
        self.title = title
        self.color = color
        self.percentage = percentage
    }
}

// MARK: - Custom Angular Donut Segment Shape
public struct DonutSegmentShape: Shape {
    public var startAngle: Angle
    public var endAngle: Angle
    public var thickness: CGFloat
    
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius - thickness
        
        path.addArc(
            center: center,
            radius: outerRadius,
            startAngle: startAngle - Angle(degrees: 90),
            endAngle: endAngle - Angle(degrees: 90),
            clockwise: false
        )
        path.addArc(
            center: center,
            radius: innerRadius,
            startAngle: endAngle - Angle(degrees: 90),
            endAngle: startAngle - Angle(degrees: 90),
            clockwise: true
        )
        path.closeSubpath()
        return path
    }
}

// MARK: - Dynamic Multi-Segment Donut Chart (Figma Frame 29:4)
public struct DonutChartView: View {
    public let segments: [DonutSegment]
    public let thickness: CGFloat
    
    public init(segments: [DonutSegment], thickness: CGFloat = 28) {
        self.segments = segments
        self.thickness = thickness
    }
    
    public var totalAngularSpanDegrees: Double {
        let total = segments.reduce(0.0) { $0 + $1.percentage }
        return total * 360.0
    }
    
    public var body: some View {
        ZStack {
            ForEach(0..<segments.count, id: \.self) { index in
                let current = segments[index]
                let startPercent = segments.prefix(index).reduce(0.0) { $0 + $1.percentage }
                let endPercent = startPercent + current.percentage
                
                DonutSegmentShape(
                    startAngle: .degrees(startPercent * 360),
                    endAngle: .degrees(endPercent * 360),
                    thickness: thickness
                )
                .fill(current.color)
            }
        }
        .frame(width: 180, height: 180)
    }
}

// MARK: - Previews
#Preview("Donut Chart - Relational Safety") {
    VStack(spacing: 20) {
        DonutChartView(segments: [
            DonutSegment(title: "Safe", color: Theme.Colors.Safety.lowRisk, percentage: 0.21),
            DonutSegment(title: "Medium Risk", color: Theme.Colors.Safety.moderateRisk, percentage: 0.39),
            DonutSegment(title: "High Risk", color: Theme.Colors.Safety.highRisk, percentage: 0.40)
        ])
        
        // Horizontal Legend
        HStack(spacing: 16) {
            Label("21% Safe", systemImage: "circle.fill")
                .foregroundColor(Theme.Colors.Safety.lowRisk)
                .font(Theme.Typography.caption)
            Label("39% Medium", systemImage: "circle.fill")
                .foregroundColor(Theme.Colors.Safety.moderateRisk)
                .font(Theme.Typography.caption)
            Label("40% High", systemImage: "circle.fill")
                .foregroundColor(Theme.Colors.Safety.highRisk)
                .font(Theme.Typography.caption)
        }
    }
    .padding(24)
    .background(Theme.Colors.cardSurface)
    .clipShape(RoundedRectangle(cornerRadius: 18))
}
