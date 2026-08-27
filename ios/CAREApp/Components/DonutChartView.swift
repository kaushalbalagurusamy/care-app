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

// MARK: - Head-to-Tail Interlocking Donut Segment Shape (Clockwise Convex Head & Concave Tail)
public struct HeadToTailDonutSegmentShape: Shape {
    public var startAngle: Angle
    public var endAngle: Angle
    public var innerRadiusRatio: CGFloat // innerRadius / outerRadius (e.g. 0.52)
    
    public init(startAngle: Angle, endAngle: Angle, innerRadiusRatio: CGFloat = 0.52) {
        self.startAngle = startAngle
        self.endAngle = endAngle
        self.innerRadiusRatio = innerRadiusRatio
    }
    
    public var animatableData: AnimatablePair<Double, Double> {
        get { AnimatablePair(startAngle.radians, endAngle.radians) }
        set {
            startAngle = .radians(newValue.first)
            endAngle = .radians(newValue.second)
        }
    }
    
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2.0
        let innerRadius = outerRadius * innerRadiusRatio
        let midRadius = (outerRadius + innerRadius) / 2.0
        let capRadius = (outerRadius - innerRadius) / 2.0
        
        let thetaStart = startAngle.radians
        let thetaEnd = endAngle.radians
        
        guard thetaEnd > thetaStart else { return path }
        
        // 1. Outer Arc from θ_start to θ_end (Clockwise along outer circle)
        path.addArc(
            center: center,
            radius: outerRadius,
            startAngle: Angle(radians: thetaStart),
            endAngle: Angle(radians: thetaEnd),
            clockwise: false
        )
        
        // 2. Head End (Convex Semi-Circle bulging forward clockwise)
        let pHead = CGPoint(
            x: center.x + midRadius * cos(thetaEnd),
            y: center.y + midRadius * sin(thetaEnd)
        )
        path.addArc(
            center: pHead,
            radius: capRadius,
            startAngle: Angle(radians: thetaEnd),
            endAngle: Angle(radians: thetaEnd + .pi),
            clockwise: false
        )
        
        // 3. Inner Arc from θ_end back to θ_start (Counter-clockwise along inner circle)
        path.addArc(
            center: center,
            radius: innerRadius,
            startAngle: Angle(radians: thetaEnd),
            endAngle: Angle(radians: thetaStart),
            clockwise: true
        )
        
        // 4. Tail End (Concave Semi-Circle scooping inward into the segment body)
        let pTail = CGPoint(
            x: center.x + midRadius * cos(thetaStart),
            y: center.y + midRadius * sin(thetaStart)
        )
        path.addArc(
            center: pTail,
            radius: capRadius,
            startAngle: Angle(radians: thetaStart + .pi),
            endAngle: Angle(radians: thetaStart),
            clockwise: true
        )
        
        path.closeSubpath()
        return path
    }
}

// MARK: - High-Fidelity Donut Chart with Head-to-Tail Clockwise Flow Geometry (Figma Frame 29:4)
public struct DonutChartView: View {
    public let segments: [DonutSegment]
    public let diameter: CGFloat
    public let strokeWidth: CGFloat
    public let gapDegrees: Double // Angular gap between segments (e.g. 7.0°)
    
    public init(
        segments: [DonutSegment],
        diameter: CGFloat = 200,
        strokeWidth: CGFloat = 34,
        gapDegrees: Double = 8.0
    ) {
        self.segments = segments
        self.diameter = diameter
        self.strokeWidth = strokeWidth
        self.gapDegrees = gapDegrees
    }
    
    private var innerRadiusRatio: CGFloat {
        let outerRadius = diameter / 2.0
        let innerRadius = max(outerRadius - strokeWidth, 10)
        return innerRadius / outerRadius
    }
    
    public var body: some View {
        ZStack {
            let totalPct = max(segments.reduce(0.0) { $0 + $1.percentage }, 0.001)
            let gapRad = Angle(degrees: gapDegrees).radians
            
            ForEach(0..<segments.count, id: \.self) { index in
                let current = segments[index]
                let startPct = segments.prefix(index).reduce(0.0) { $0 + $1.percentage } / totalPct
                let endPct = (segments.prefix(index).reduce(0.0) { $0 + $1.percentage } + current.percentage) / totalPct
                
                let baseStartRad = Angle(degrees: -90 + (startPct * 360)).radians
                let baseEndRad = Angle(degrees: -90 + (endPct * 360)).radians
                
                let trimmedStartRad = baseStartRad + (gapRad / 2.0)
                let trimmedEndRad = max(baseEndRad - (gapRad / 2.0), trimmedStartRad)
                
                HeadToTailDonutSegmentShape(
                    startAngle: Angle(radians: trimmedStartRad),
                    endAngle: Angle(radians: trimmedEndRad),
                    innerRadiusRatio: innerRadiusRatio
                )
                .fill(current.color)
            }
        }
        .frame(width: diameter, height: diameter)
    }
}

// MARK: - Previews
#Preview("High Fidelity Donut Charts") {
    VStack(spacing: 32) {
        // 1. Relational Safety 3-Tier Donut
        BubbleCardContainer(title: "Relational Safety", showInfoIcon: true) {
            VStack(spacing: 20) {
                DonutChartView(
                    segments: [
                        DonutSegment(title: "Safe", color: Theme.Colors.Safety.lowRisk, percentage: 0.21),
                        DonutSegment(title: "Medium Risk", color: Theme.Colors.Safety.moderateRisk, percentage: 0.39),
                        DonutSegment(title: "High Risk", color: Theme.Colors.Safety.highRisk, percentage: 0.40)
                    ]
                )
                .frame(maxWidth: .infinity)
                
                // Legend
                VStack(spacing: 8) {
                    HStack {
                        Circle().fill(Theme.Colors.Safety.lowRisk).frame(width: 10, height: 10)
                        Text("Safe").font(Theme.Typography.caption).foregroundColor(Theme.Colors.textPrimary)
                        Spacer()
                        Text("21%").font(Theme.Typography.caption).foregroundColor(Theme.Colors.textPrimary)
                    }
                    HStack {
                        Circle().fill(Theme.Colors.Safety.moderateRisk).frame(width: 10, height: 10)
                        Text("Medium Risk").font(Theme.Typography.caption).foregroundColor(Theme.Colors.textPrimary)
                        Spacer()
                        Text("39%").font(Theme.Typography.caption).foregroundColor(Theme.Colors.textPrimary)
                    }
                    HStack {
                        Circle().fill(Theme.Colors.Safety.highRisk).frame(width: 10, height: 10)
                        Text("High Risk").font(Theme.Typography.caption).foregroundColor(Theme.Colors.textPrimary)
                        Spacer()
                        Text("40%").font(Theme.Typography.caption).foregroundColor(Theme.Colors.textPrimary)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        
        // 2. Score Composition 4-CARE-Domain Donut
        BubbleCardContainer(title: "Score Composition") {
            DonutChartView(
                segments: [
                    DonutSegment(title: "Calm", color: Theme.Colors.Domains.calm, percentage: 0.25),
                    DonutSegment(title: "Accepted", color: Theme.Colors.Domains.accepted, percentage: 0.25),
                    DonutSegment(title: "Resonant", color: Theme.Colors.Domains.resonant, percentage: 0.25),
                    DonutSegment(title: "Energetic", color: Theme.Colors.Domains.energetic, percentage: 0.25)
                ]
            )
            .frame(maxWidth: .infinity)
        }
    }
    .padding(20)
    .background(Theme.Colors.background)
}
