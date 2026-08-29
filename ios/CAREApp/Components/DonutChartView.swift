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

// MARK: - Arc-Rectangular Donut Segment Shape with Constant-Width Parallel Slits & Soft Fillet Corners
public struct ParallelSlitDonutSegmentShape: Shape {
    public var startAngle: Angle
    public var endAngle: Angle
    public var innerRadiusRatio: CGFloat // innerRadius / outerRadius (e.g. 0.52)
    public var gapWidth: CGFloat         // Constant slit gap width in points (e.g. 8.0)
    public var cornerRadius: CGFloat     // 50% softer fillet radius (e.g. 9.0)
    
    public init(
        startAngle: Angle,
        endAngle: Angle,
        innerRadiusRatio: CGFloat = 0.52,
        gapWidth: CGFloat = 8.0,
        cornerRadius: CGFloat = 9.0
    ) {
        self.startAngle = startAngle
        self.endAngle = endAngle
        self.innerRadiusRatio = innerRadiusRatio
        self.gapWidth = gapWidth
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
        
        let halfGap = gapWidth / 2.0
        
        // Exact trigonometric offset so the gap between adjacent slices is a constant width (2 * halfGap)
        let deltaO_gap = asin(min(halfGap / outerRadius, 0.99))
        let deltaI_gap = asin(min(halfGap / innerRadius, 0.99))
        
        let t1 = startAngle.radians
        let t2 = endAngle.radians
        
        let outerStart = t1 + deltaO_gap
        let outerEnd = t2 - deltaO_gap
        let innerStart = t1 + deltaI_gap
        let innerEnd = t2 - deltaI_gap
        
        guard outerEnd > outerStart, innerEnd > innerStart else { return path }
        
        // Soft fillet corner radius (50% softer, clamped safely)
        let r_c = min(cornerRadius, radialThickness / 2.5)
        
        let deltaO_fillet = min(r_c / outerRadius, (outerEnd - outerStart) / 2.5)
        let deltaI_fillet = min(r_c / innerRadius, (innerEnd - innerStart) / 2.5)
        
        // 4 Corner Vertices (where the parallel straight edges meet the outer and inner circles)
        let v_outer_start = CGPoint(x: center.x + outerRadius * cos(outerStart), y: center.y + outerRadius * sin(outerStart))
        let v_outer_end = CGPoint(x: center.x + outerRadius * cos(outerEnd), y: center.y + outerRadius * sin(outerEnd))
        let v_inner_end = CGPoint(x: center.x + innerRadius * cos(innerEnd), y: center.y + innerRadius * sin(innerEnd))
        let v_inner_start = CGPoint(x: center.x + innerRadius * cos(innerStart), y: center.y + innerRadius * sin(innerStart))
        
        // Arc start and end endpoints (inset by fillet angle)
        let p_outer_arc_start = CGPoint(x: center.x + outerRadius * cos(outerStart + deltaO_fillet), y: center.y + outerRadius * sin(outerStart + deltaO_fillet))
        let p_outer_arc_end = CGPoint(x: center.x + outerRadius * cos(outerEnd - deltaO_fillet), y: center.y + outerRadius * sin(outerEnd - deltaO_fillet))
        
        let p_inner_arc_end = CGPoint(x: center.x + innerRadius * cos(innerEnd - deltaI_fillet), y: center.y + innerRadius * sin(innerEnd - deltaI_fillet))
        let p_inner_arc_start = CGPoint(x: center.x + innerRadius * cos(innerStart + deltaI_fillet), y: center.y + innerRadius * sin(innerStart + deltaI_fillet))
        
        // Straight leading edge (outerEnd -> innerEnd) unit direction
        let v_lead = CGPoint(x: v_inner_end.x - v_outer_end.x, y: v_inner_end.y - v_outer_end.y)
        let lead_len = sqrt(v_lead.x * v_lead.x + v_lead.y * v_lead.y)
        let u_lead = lead_len > 0 ? CGPoint(x: v_lead.x / lead_len, y: v_lead.y / lead_len) : CGPoint.zero
        
        let p_lead_start = CGPoint(x: v_outer_end.x + u_lead.x * r_c, y: v_outer_end.y + u_lead.y * r_c)
        let p_lead_end = CGPoint(x: v_inner_end.x - u_lead.x * r_c, y: v_inner_end.y - u_lead.y * r_c)
        
        // Straight trailing edge (innerStart -> outerStart) unit direction
        let v_trail = CGPoint(x: v_outer_start.x - v_inner_start.x, y: v_outer_start.y - v_inner_start.y)
        let trail_len = sqrt(v_trail.x * v_trail.x + v_trail.y * v_trail.y)
        let u_trail = trail_len > 0 ? CGPoint(x: v_trail.x / trail_len, y: v_trail.y / trail_len) : CGPoint.zero
        
        let p_trail_start = CGPoint(x: v_inner_start.x + u_trail.x * r_c, y: v_inner_start.y + u_trail.y * r_c)
        let p_trail_end = CGPoint(x: v_outer_start.x - u_trail.x * r_c, y: v_outer_start.y - u_trail.y * r_c)
        
        // Path construction
        path.move(to: p_outer_arc_start)
        
        // 1. Outer Circular Arc
        path.addArc(
            center: center,
            radius: outerRadius,
            startAngle: Angle(radians: outerStart + deltaO_fillet),
            endAngle: Angle(radians: outerEnd - deltaO_fillet),
            clockwise: false
        )
        
        // 2. Corner 1 (Outer End Fillet)
        path.addQuadCurve(to: p_lead_start, control: v_outer_end)
        
        // 3. Leading Straight Edge (Strictly parallel to dividing ray t2)
        path.addLine(to: p_lead_end)
        
        // 4. Corner 2 (Inner End Fillet)
        path.addQuadCurve(to: p_inner_arc_end, control: v_inner_end)
        
        // 5. Inner Circular Arc
        path.addArc(
            center: center,
            radius: innerRadius,
            startAngle: Angle(radians: innerEnd - deltaI_fillet),
            endAngle: Angle(radians: innerStart + deltaI_fillet),
            clockwise: true
        )
        
        // 6. Corner 3 (Inner Start Fillet)
        path.addQuadCurve(to: p_trail_start, control: v_inner_start)
        
        // 7. Trailing Straight Edge (Strictly parallel to dividing ray t1)
        path.addLine(to: p_trail_end)
        
        // 8. Corner 4 (Outer Start Fillet)
        path.addQuadCurve(to: p_outer_arc_start, control: v_outer_start)
        
        path.closeSubpath()
        return path
    }
}

// MARK: - High-Fidelity Donut Chart with Parallel-Slit Geometry & Soft Fillets
public struct DonutChartView: View {
    public let segments: [DonutSegment]
    public let diameter: CGFloat
    public let strokeWidth: CGFloat
    public let gapWidth: CGFloat
    public let cornerRadius: CGFloat
    
    public var totalAngularSpanDegrees: Double {
        return segments.reduce(0.0) { $0 + $1.percentage } * 360.0
    }
    
    public init(
        segments: [DonutSegment],
        diameter: CGFloat = 190,
        strokeWidth: CGFloat = 46,
        gapWidth: CGFloat = 8.0,
        cornerRadius: CGFloat = 9.0
    ) {
        self.segments = segments
        self.diameter = diameter
        self.strokeWidth = strokeWidth
        self.gapWidth = gapWidth
        self.cornerRadius = cornerRadius
    }
    
    // Backwards compatibility initializer
    public init(
        segments: [DonutSegment],
        diameter: CGFloat = 190,
        strokeWidth: CGFloat = 46,
        gapDegrees: Double,
        cornerRadius: CGFloat = 9.0
    ) {
        self.segments = segments
        self.diameter = diameter
        self.strokeWidth = strokeWidth
        self.gapWidth = 8.0
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
            
            ForEach(0..<segments.count, id: \.self) { index in
                let current = segments[index]
                let startPct = segments.prefix(index).reduce(0.0) { $0 + $1.percentage } / totalPct
                let endPct = (segments.prefix(index).reduce(0.0) { $0 + $1.percentage } + current.percentage) / totalPct
                
                let baseStartAngle = Angle(degrees: -90 + (startPct * 360))
                let baseEndAngle = Angle(degrees: -90 + (endPct * 360))
                
                ParallelSlitDonutSegmentShape(
                    startAngle: baseStartAngle,
                    endAngle: baseEndAngle,
                    innerRadiusRatio: innerRadiusRatio,
                    gapWidth: gapWidth,
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
