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

// MARK: - High-Fidelity Donut Chart with Rounded Stroke Caps & Angular Gaps (Figma Frame 29:4)
public struct DonutChartView: View {
    public let segments: [DonutSegment]
    public let diameter: CGFloat
    public let strokeWidth: CGFloat
    public let gapDegrees: Double // Angular gap between segments (e.g. 6.0°)
    
    public init(
        segments: [DonutSegment],
        diameter: CGFloat = 200,
        strokeWidth: CGFloat = 32,
        gapDegrees: Double = 6.0
    ) {
        self.segments = segments
        self.diameter = diameter
        self.strokeWidth = strokeWidth
        self.gapDegrees = gapDegrees
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
                
                // Convert gap degrees into fraction of circumference
                let gapFraction = (gapDegrees / 360.0) / 2.0
                let trimmedStart = min(startPercent + gapFraction, endPercent)
                let trimmedEnd = max(endPercent - gapFraction, trimmedStart)
                
                Circle()
                    .trim(from: CGFloat(trimmedStart), to: CGFloat(trimmedEnd))
                    .stroke(
                        current.color,
                        style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: diameter - strokeWidth, height: diameter - strokeWidth)
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
