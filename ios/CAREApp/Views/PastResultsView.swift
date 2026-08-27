import SwiftUI

// MARK: - Screen 10: Historical Past Results & Relational Trends (Figma Frame 95:2)
public struct PastResultsView: View {
    public let router: AppRouter
    
    // Accordion Expansion States matching Figma Frame 95:2
    @State private var isTotalScoresExpanded: Bool = false
    @State private var isCareResultsExpanded: Bool = true
    @State private var isRelationalSafetyExpanded: Bool = true
    @State private var isIndividualResultsExpanded: Bool = true
    
    // Sub-item Expansion States
    @State private var expandedDomain: CAREDomain? = nil
    @State private var expandedIndividual: String? = "Sarah Mitchell"
    
    private let individuals = [
        "Sarah Mitchell",
        "James Rivera",
        "Emily Chen",
        "David Thompson",
        "Anya Patel"
    ]
    
    public init(router: AppRouter) {
        self.router = router
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Standardized Modular Header Bar
            HeaderNavBar(
                showBackButton: true,
                showHomeButton: true,
                showChartButton: true,
                showProfileButton: true,
                onBack: { router.pop() },
                onHome: { router.popToRoot() },
                onChart: {},
                onProfile: {}
            )
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    
                    // Title Section (Figma Frame 95:2)
                    Text("Past Results")
                        .font(Theme.Typography.poppins(.bold, size: 28))
                        .foregroundColor(Theme.Colors.textPrimary)
                        .padding(.top, 4)
                    
                    // MARK: 1. Total Scores Bubble Card (Collapsed in Figma 95:2)
                    CollapsibleCardContainer(
                        title: "Total Scores",
                        isExpanded: isTotalScoresExpanded,
                        onToggle: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                isTotalScoresExpanded.toggle()
                            }
                        }
                    ) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Overall assessment scores across historical evaluations.")
                                .font(Theme.Typography.poppins(.regular, size: 14))
                                .foregroundColor(Theme.Colors.textSecondary)
                        }
                        .padding(.top, 4)
                    }
                    
                    // MARK: 2. C.A.R.E. Results Bubble Card (Expanded in Figma 95:2)
                    CollapsibleCardContainer(
                        title: "C.A.R.E. Results",
                        isExpanded: isCareResultsExpanded,
                        onToggle: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                isCareResultsExpanded.toggle()
                            }
                        }
                    ) {
                        VStack(spacing: 0) {
                            careDomainRow(domain: .calm, title: "Calm", color: Theme.Colors.Domains.calm)
                            Divider().background(Theme.Colors.dividerSubtle)
                            careDomainRow(domain: .accepted, title: "Accepted", color: Theme.Colors.Domains.accepted)
                            Divider().background(Theme.Colors.dividerSubtle)
                            careDomainRow(domain: .resonant, title: "Resonant", color: Theme.Colors.Domains.resonant)
                            Divider().background(Theme.Colors.dividerSubtle)
                            careDomainRow(domain: .energetic, title: "Energetic", color: Theme.Colors.Domains.energetic)
                        }
                        .padding(.top, 4)
                    }
                    
                    // MARK: 3. Relational Safety Bubble Card (Expanded with Multi-Line Chart)
                    CollapsibleCardContainer(
                        title: "Relational Safety",
                        isExpanded: isRelationalSafetyExpanded,
                        onToggle: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                isRelationalSafetyExpanded.toggle()
                            }
                        }
                    ) {
                        RelationalSafetyTrendChart()
                            .padding(.top, 8)
                    }
                    
                    // MARK: 4. Results by Individual Bubble Card (Expanded with Sarah Mitchell sub-chart)
                    CollapsibleCardContainer(
                        title: "Results by Individual",
                        isExpanded: isIndividualResultsExpanded,
                        onToggle: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                isIndividualResultsExpanded.toggle()
                            }
                        }
                    ) {
                        VStack(spacing: 0) {
                            ForEach(0..<individuals.count, id: \.self) { index in
                                let name = individuals[index]
                                let isItemExpanded = (expandedIndividual == name)
                                
                                VStack(spacing: 0) {
                                    Button(action: {
                                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                            if isItemExpanded {
                                                expandedIndividual = nil
                                            } else {
                                                expandedIndividual = name
                                            }
                                        }
                                    }) {
                                        HStack {
                                            Text(name)
                                                .font(Theme.Typography.poppins(.bold, size: 16))
                                                .foregroundColor(Theme.Colors.textPrimary)
                                            
                                            Spacer()
                                            
                                            Image(systemName: isItemExpanded ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill")
                                                .font(.system(size: 11, weight: .bold))
                                                .foregroundColor(Theme.Colors.primary)
                                        }
                                        .padding(.vertical, 14)
                                    }
                                    .buttonStyle(.plain)
                                    
                                    if isItemExpanded {
                                        IndividualScoreBandChart()
                                            .padding(.bottom, 12)
                                    }
                                    
                                    if index < individuals.count - 1 {
                                        Divider().background(Theme.Colors.dividerSubtle)
                                    }
                                }
                            }
                        }
                        .padding(.top, 4)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
        .background(Theme.Colors.background)
    }
    
    // MARK: - C.A.R.E. Domain Sub-Accordion Row
    private func careDomainRow(domain: CAREDomain, title: String, color: Color) -> some View {
        let isExpanded = (expandedDomain == domain)
        
        return VStack(spacing: 0) {
            Button(action: {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    if isExpanded {
                        expandedDomain = nil
                    } else {
                        expandedDomain = domain
                    }
                }
            }) {
                HStack(spacing: 12) {
                    Circle()
                        .fill(color)
                        .frame(width: 10, height: 10)
                    
                    Text(title)
                        .font(Theme.Typography.poppins(.bold, size: 16))
                        .foregroundColor(Theme.Colors.textPrimary)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Theme.Colors.primary)
                }
                .padding(.vertical, 14)
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 6) {
                    Text(domain.explanation)
                        .font(Theme.Typography.poppins(.regular, size: 13.5))
                        .foregroundColor(Theme.Colors.textSecondary)
                        .lineSpacing(3)
                        .padding(.leading, 22)
                        .padding(.bottom, 12)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

// MARK: - Collapsible Card Container (Figma Frame 95:2)
public struct CollapsibleCardContainer<Content: View>: View {
    public let title: String
    public let isExpanded: Bool
    public let onToggle: () -> Void
    @ViewBuilder public let content: () -> Content
    
    public init(
        title: String,
        isExpanded: Bool,
        onToggle: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.isExpanded = isExpanded
        self.onToggle = onToggle
        self.content = content
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header Row
            Button(action: onToggle) {
                HStack {
                    Text(title)
                        .font(Theme.Typography.poppins(.bold, size: 18))
                        .foregroundColor(Theme.Colors.textPrimary)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Theme.Colors.primary)
                }
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                content()
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.Colors.surfaceSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

// MARK: - Relational Safety Multi-Line Trend Chart (Figma Frame 95:2)
public struct RelationalSafetyTrendChart: View {
    // Dates: 5/16, 5/25, 5/29
    private let dates = ["5/16", "5/25", "5/29"]
    
    // Y-Axis Labels: 100%, 75%, 50%, 25%, 0%
    private let yLabels = ["100%", "75%", "50%", "25%", "0%"]
    
    // Data series (values 0.0 to 1.0)
    // Safe (Green): 60% -> 75% -> 85%
    private let safePoints: [CGFloat] = [0.60, 0.75, 0.85]
    // Moderate (Yellow): 30% -> 20% -> 10%
    private let moderatePoints: [CGFloat] = [0.30, 0.20, 0.10]
    // High Risk (Coral): 10% -> 5% -> 5%
    private let highRiskPoints: [CGFloat] = [0.10, 0.05, 0.05]
    
    public var body: some View {
        VStack(spacing: 14) {
            // Main Chart Canvas
            HStack(alignment: .top, spacing: 8) {
                // Y-Axis Labels
                VStack(alignment: .trailing, spacing: 0) {
                    ForEach(0..<yLabels.count, id: \.self) { idx in
                        Text(yLabels[idx])
                            .font(Theme.Typography.poppins(.regular, size: 10.5))
                            .foregroundColor(Theme.Colors.textSecondary)
                        if idx < yLabels.count - 1 {
                            Spacer()
                        }
                    }
                }
                .frame(width: 36, height: 160)
                
                // Chart Plot Area
                VStack(spacing: 0) {
                    GeometryReader { geo in
                        let w = geo.size.width
                        let h = geo.size.height
                        
                        ZStack(alignment: .bottomLeading) {
                            // Horizontal Grid Lines
                            VStack(spacing: 0) {
                                ForEach(0..<5, id: \.self) { i in
                                    Rectangle()
                                        .fill(Theme.Colors.dividerSubtle.opacity(0.8))
                                        .frame(height: 1)
                                    if i < 4 {
                                        Spacer()
                                    }
                                }
                            }
                            
                            // Y-Axis Left Border
                            Rectangle()
                                .fill(Theme.Colors.textSecondary.opacity(0.4))
                                .frame(width: 1)
                                .frame(maxHeight: .infinity, alignment: .leading)
                            
                            // X-Axis Bottom Border
                            Rectangle()
                                .fill(Theme.Colors.textSecondary.opacity(0.4))
                                .frame(height: 1)
                                .frame(maxWidth: .infinity, alignment: .bottom)
                            
                            // 3 Trend Lines
                            let xCoords = [w * 0.20, w * 0.55, w * 0.88]
                            
                            // 1. Safe Line (Green)
                            trendLinePath(xCoords: xCoords, values: safePoints, height: h)
                                .stroke(Theme.Colors.Safety.lowRisk, lineWidth: 2.5)
                            
                            trendPointsView(xCoords: xCoords, values: safePoints, height: h, color: Theme.Colors.Safety.lowRisk)
                            
                            // 2. Moderate Line (Yellow)
                            trendLinePath(xCoords: xCoords, values: moderatePoints, height: h)
                                .stroke(Theme.Colors.Safety.moderateRisk, lineWidth: 2.5)
                            
                            trendPointsView(xCoords: xCoords, values: moderatePoints, height: h, color: Theme.Colors.Safety.moderateRisk)
                            
                            // 3. High Risk Line (Red/Coral)
                            trendLinePath(xCoords: xCoords, values: highRiskPoints, height: h)
                                .stroke(Theme.Colors.Safety.highRisk, lineWidth: 2.5)
                            
                            trendPointsView(xCoords: xCoords, values: highRiskPoints, height: h, color: Theme.Colors.Safety.highRisk)
                        }
                    }
                    .frame(height: 160)
                    
                    // X-Axis Labels
                    HStack {
                        Spacer().frame(width: 30)
                        Text("5/16")
                            .font(Theme.Typography.poppins(.regular, size: 11))
                            .foregroundColor(Theme.Colors.textSecondary)
                        Spacer()
                        Text("5/25")
                            .font(Theme.Typography.poppins(.regular, size: 11))
                            .foregroundColor(Theme.Colors.textSecondary)
                        Spacer()
                        Text("5/29")
                            .font(Theme.Typography.poppins(.regular, size: 11))
                            .foregroundColor(Theme.Colors.textSecondary)
                        Spacer().frame(width: 15)
                    }
                    .padding(.top, 6)
                }
            }
            
            // Legend Row (Figma Frame 95:2)
            HStack(spacing: 14) {
                HStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Theme.Colors.Safety.lowRisk)
                        .frame(width: 12, height: 12)
                    Text("Safe")
                        .font(Theme.Typography.poppins(.medium, size: 12))
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                
                HStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Theme.Colors.Safety.moderateRisk)
                        .frame(width: 12, height: 12)
                    Text("Moderate")
                        .font(Theme.Typography.poppins(.medium, size: 12))
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                
                HStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Theme.Colors.Safety.highRisk)
                        .frame(width: 12, height: 12)
                    Text("High Risk")
                        .font(Theme.Typography.poppins(.medium, size: 12))
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "info.circle")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(Theme.Colors.primary)
            }
            .padding(.top, 4)
        }
    }
    
    private func trendLinePath(xCoords: [CGFloat], values: [CGFloat], height: CGFloat) -> Path {
        var path = Path()
        guard xCoords.count == values.count, !xCoords.isEmpty else { return path }
        
        let p0 = CGPoint(x: xCoords[0], y: height * (1.0 - values[0]))
        path.move(to: p0)
        
        for i in 1..<xCoords.count {
            let pt = CGPoint(x: xCoords[i], y: height * (1.0 - values[i]))
            path.addLine(to: pt)
        }
        return path
    }
    
    @ViewBuilder
    private func trendPointsView(xCoords: [CGFloat], values: [CGFloat], height: CGFloat, color: Color) -> some View {
        ForEach(0..<xCoords.count, id: \.self) { i in
            let px = xCoords[i]
            let py = height * (1.0 - values[i])
            Circle()
                .fill(color)
                .frame(width: 7, height: 7)
                .position(x: px, y: py)
        }
    }
}

// MARK: - Individual Score 3-Tier Colored Band Chart (Figma Frame 95:2)
public struct IndividualScoreBandChart: View {
    // Y-Axis: 100, 67, 33, 0
    private let yLabels = ["100", "67", "33", "0"]
    
    // Scores: 31 (5/16), 59 (5/25), 83 (5/29)
    private let scores: [CGFloat] = [31, 59, 83]
    private let dates = ["5/16", "5/25", "5/29"]
    
    public var body: some View {
        VStack(spacing: 14) {
            HStack(alignment: .top, spacing: 8) {
                // Y-Axis Labels
                VStack(alignment: .trailing, spacing: 0) {
                    ForEach(0..<yLabels.count, id: \.self) { idx in
                        Text(yLabels[idx])
                            .font(Theme.Typography.poppins(.regular, size: 10.5))
                            .foregroundColor(Theme.Colors.textSecondary)
                        if idx < yLabels.count - 1 {
                            Spacer()
                        }
                    }
                }
                .frame(width: 26, height: 160)
                
                // Band Chart Plot Area
                VStack(spacing: 0) {
                    GeometryReader { geo in
                        let w = geo.size.width
                        let h = geo.size.height
                        
                        ZStack(alignment: .bottomLeading) {
                            // 3 Horizontal Colored Background Bands (Figma Frame 95:2)
                            VStack(spacing: 0) {
                                // Top Band: Safe (#D1F2D9 / Light Green)
                                Rectangle()
                                    .fill(Color(red: 0.82, green: 0.94, blue: 0.85))
                                    .frame(height: h / 3.0)
                                
                                // Middle Band: Moderate (#FDF0D0 / Light Amber)
                                Rectangle()
                                    .fill(Color(red: 0.99, green: 0.94, blue: 0.82))
                                    .frame(height: h / 3.0)
                                
                                // Bottom Band: High Risk (#FCDAD7 / Light Pink)
                                Rectangle()
                                    .fill(Color(red: 0.98, green: 0.85, blue: 0.84))
                                    .frame(height: h / 3.0)
                            }
                            
                            // Y-Axis and Horizontal Dividers
                            VStack(spacing: 0) {
                                Rectangle().fill(Theme.Colors.textSecondary.opacity(0.3)).frame(height: 1)
                                Spacer()
                                Rectangle().fill(Theme.Colors.textSecondary.opacity(0.3)).frame(height: 1)
                                Spacer()
                                Rectangle().fill(Theme.Colors.textSecondary.opacity(0.3)).frame(height: 1)
                                Spacer()
                                Rectangle().fill(Theme.Colors.textSecondary.opacity(0.3)).frame(height: 1)
                            }
                            
                            Rectangle()
                                .fill(Theme.Colors.textSecondary.opacity(0.4))
                                .frame(width: 1)
                                .frame(maxHeight: .infinity, alignment: .leading)
                            
                            // Score Line connecting 31 -> 59 -> 83
                            let xCoords = [w * 0.22, w * 0.55, w * 0.86]
                            
                            scoreLinePath(xCoords: xCoords, scores: scores, height: h)
                                .stroke(Color(red: 0.22, green: 0.55, blue: 0.78), lineWidth: 2.5)
                            
                            // Data Point Markers & Value Callout Labels
                            ForEach(0..<scores.count, id: \.self) { idx in
                                let px = xCoords[idx]
                                let py = h * (1.0 - (scores[idx] / 100.0))
                                
                                VStack(spacing: 2) {
                                    Text("\(Int(scores[idx]))")
                                        .font(Theme.Typography.poppins(.bold, size: 12))
                                        .foregroundColor(Theme.Colors.textPrimary)
                                    
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 8, height: 8)
                                        .overlay(
                                            Circle()
                                                .stroke(Color(red: 0.22, green: 0.55, blue: 0.78), lineWidth: 2)
                                        )
                                }
                                .position(x: px, y: py - 6)
                            }
                        }
                    }
                    .frame(height: 160)
                    .clipShape(Rectangle())
                    
                    // X-Axis Labels
                    HStack {
                        Spacer().frame(width: 30)
                        Text("5/16")
                            .font(Theme.Typography.poppins(.regular, size: 11))
                            .foregroundColor(Theme.Colors.textSecondary)
                        Spacer()
                        Text("5/25")
                            .font(Theme.Typography.poppins(.regular, size: 11))
                            .foregroundColor(Theme.Colors.textSecondary)
                        Spacer()
                        Text("5/29")
                            .font(Theme.Typography.poppins(.regular, size: 11))
                            .foregroundColor(Theme.Colors.textSecondary)
                        Spacer().frame(width: 15)
                    }
                    .padding(.top, 6)
                }
            }
            
            // Legend Row
            HStack(spacing: 14) {
                HStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Theme.Colors.Safety.lowRisk)
                        .frame(width: 12, height: 12)
                    Text("Safe")
                        .font(Theme.Typography.poppins(.medium, size: 12))
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                
                HStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Theme.Colors.Safety.moderateRisk)
                        .frame(width: 12, height: 12)
                    Text("Moderate")
                        .font(Theme.Typography.poppins(.medium, size: 12))
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                
                HStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Theme.Colors.Safety.highRisk)
                        .frame(width: 12, height: 12)
                    Text("High Risk")
                        .font(Theme.Typography.poppins(.medium, size: 12))
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "info.circle")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(Theme.Colors.primary)
            }
            .padding(.top, 4)
        }
    }
    
    private func scoreLinePath(xCoords: [CGFloat], scores: [CGFloat], height: CGFloat) -> Path {
        var path = Path()
        guard xCoords.count == scores.count, !xCoords.isEmpty else { return path }
        
        let p0 = CGPoint(x: xCoords[0], y: height * (1.0 - (scores[0] / 100.0)))
        path.move(to: p0)
        
        for i in 1..<xCoords.count {
            let pt = CGPoint(x: xCoords[i], y: height * (1.0 - (scores[i] / 100.0)))
            path.addLine(to: pt)
        }
        return path
    }
}

// MARK: - Previews
#Preview("Past Results View") {
    PastResultsView(router: AppRouter())
}
