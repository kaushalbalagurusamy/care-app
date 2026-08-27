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

// MARK: - Arc-Rectangular Donut Segment Shape with Soft Fillet Corners
public struct ArcRectangularDonutSegmentShape: Shape {
    public var startAngle: Angle
    public var endAngle: Angle
    public var innerRadiusRatio: CGFloat // innerRadius / outerRadius (e.g. 0.52)
    public var cornerRadius: CGFloat     // Fillet radius (e.g. 6.0)
    
    public init(
        startAngle: Angle,
        endAngle: Angle,
        innerRadiusRatio: CGFloat = 0.52,
        cornerRadius: CGFloat = 6.0
    ) {
        self.startAngle = startAngle
        self.endAngle = endAngle
        self.innerRadiusRatio = innerRadiusRatio
        self.cornerRadius = cornerRadius
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
        let radialThickness = outerRadius - innerRadius
        
        let r_c = min(cornerRadius, radialThickness / 3.0)
        
        let a1 = startAngle.radians
        let a2 = endAngle.radians
        let span = a2 - a1
        
        guard span > 0.01 else { return path }
        
        let deltaO = min(r_c / outerRadius, span / 3.0)
        let deltaI = min(r_c / innerRadius, span / 3.0)
        
        let p_o1 = CGPoint(x: center.x + outerRadius * cos(a1 + deltaO), y: center.y + outerRadius * sin(a1 + deltaO))
        let v2 = CGPoint(x: center.x + outerRadius * cos(a2), y: center.y + outerRadius * sin(a2))
        let p_r2 = CGPoint(x: center.x + (outerRadius - r_c) * cos(a2), y: center.y + (outerRadius - r_c) * sin(a2))
        let p_r2_in = CGPoint(x: center.x + (innerRadius + r_c) * cos(a2), y: center.y + (innerRadius + r_c) * sin(a2))
        let v3 = CGPoint(x: center.x + innerRadius * cos(a2), y: center.y + innerRadius * sin(a2))
        let p_i2 = CGPoint(x: center.x + innerRadius * cos(a2 - deltaI), y: center.y + innerRadius * sin(a2 - deltaI))
        let v4 = CGPoint(x: center.x + innerRadius * cos(a1), y: center.y + innerRadius * sin(a1))
        let p_r1_in = CGPoint(x: center.x + (innerRadius + r_c) * cos(a1), y: center.y + (innerRadius + r_c) * sin(a1))
        let p_r1_out = CGPoint(x: center.x + (outerRadius - r_c) * cos(a1), y: center.y + (outerRadius - r_c) * sin(a1))
        let v1 = CGPoint(x: center.x + outerRadius * cos(a1), y: center.y + outerRadius * sin(a1))
        
        // 1. Move to Outer Start
        path.move(to: p_o1)
        
        // 2. Outer Arc
        path.addArc(
            center: center,
            radius: outerRadius,
            startAngle: Angle(radians: a1 + deltaO),
            endAngle: Angle(radians: a2 - deltaO),
            clockwise: false
        )
        
        // 3. Corner 1 (Outer End Fillet)
        path.addQuadCurve(to: p_r2, control: v2)
        
        // 4. Straight Radial Edge
        path.addLine(to: p_r2_in)
        
        // 5. Corner 2 (Inner End Fillet)
        path.addQuadCurve(to: p_i2, control: v3)
        
        // 6. Inner Arc
        path.addArc(
            center: center,
            radius: innerRadius,
            startAngle: Angle(radians: a2 - deltaI),
            endAngle: Angle(radians: a1 + deltaI),
            clockwise: true
        )
        
        // 7. Corner 3 (Inner Start Fillet)
        path.addQuadCurve(to: p_r1_in, control: v4)
        
        // 8. Straight Radial Edge
        path.addLine(to: p_r1_out)
        
        // 9. Corner 4 (Outer Start Fillet)
        path.addQuadCurve(to: p_o1, control: v1)
        
        path.closeSubpath()
        return path
    }
}

// MARK: - High-Fidelity Donut Chart with Arc-Rectangular Fillet Geometry
public struct DonutChartView: View {
    public let segments: [DonutSegment]
    public let diameter: CGFloat
    public let strokeWidth: CGFloat
    public let gapDegrees: Double
    public let cornerRadius: CGFloat
    
    public init(
        segments: [DonutSegment],
        diameter: CGFloat = 190,
        strokeWidth: CGFloat = 46,
        gapDegrees: Double = 7.0,
        cornerRadius: CGFloat = 6.0
    ) {
        self.segments = segments
        self.diameter = diameter
        self.strokeWidth = strokeWidth
        self.gapDegrees = gapDegrees
        self.cornerRadius = cornerRadius
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
                
                ArcRectangularDonutSegmentShape(
                    startAngle: Angle(radians: trimmedStartRad),
                    endAngle: Angle(radians: trimmedEndRad),
                    innerRadiusRatio: innerRadiusRatio,
                    cornerRadius: cornerRadius
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
