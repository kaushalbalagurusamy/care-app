import SwiftUI

// MARK: - Screen 10: Historical Past Results & Relational Trends (Figma Frame 95:2)
public struct PastResultsView: View {
    public let router: AppRouter
    @Environment(AppEnvironment.self) private var appEnvironment
    
    // Live Historical Sessions
    @State private var savedHistory: [AssessmentResult] = []
    
    // Search & Individual Selection
    @State private var searchText: String = ""
    @State private var selectedIndividual: String? = "Sarah Mitchell"
    
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
    
    private var availableIndividuals: [String] {
        var names: [String] = []
        for session in savedHistory {
            for result in session.individualResults {
                let name = result.participant.person.name
                if !names.contains(name) {
                    names.append(name)
                }
            }
        }
        for defaultName in individuals {
            if !names.contains(defaultName) {
                names.append(defaultName)
            }
        }
        return names
    }
    
    private var displayedIndividuals: [String] {
        let all = availableIndividuals
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return Array(all.prefix(5))
        } else {
            return FuzzyMatcher.filterStrings(query: trimmed, candidates: all)
        }
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Standardized Modular Header Bar
            HeaderNavBar()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    
                    // Title Section (Figma Frame 95:2)
                    Text("Past Results")
                        .font(Theme.Typography.poppins(.bold, size: 28))
                        .foregroundColor(Theme.Colors.textPrimary)
                        .padding(.top, 4)
                    
                    // MARK: 1. C.A.R.E. Results Bubble Card (Static, Single 4-Line Multi-Trend Graph)
                    BubbleCardContainer(
                        title: "C.A.R.E. Results",
                        isCollapsible: false
                    ) {
                        CARETrendChart()
                            .padding(.top, 8)
                    }
                    
                    // MARK: 2. Relational Safety Bubble Card (Static, 3-Line Multi-Trend Graph)
                    BubbleCardContainer(
                        title: "Relational Safety",
                        isCollapsible: false
                    ) {
                        RelationalSafetyTrendChart()
                            .padding(.top, 8)
                    }
                    
                    // MARK: 3. Results by Individual Bubble Card (Static, Search Bar & Recent Selection)
                    BubbleCardContainer(
                        title: "Results by Individual",
                        isCollapsible: false
                    ) {
                        VStack(alignment: .leading, spacing: 14) {
                            // Theme-matching search bar
                            HStack(spacing: 8) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Theme.Colors.textSecondary)
                                
                                TextField("Search individuals...", text: $searchText)
                                    .font(Theme.Typography.poppins(.regular, size: 14))
                                    .foregroundColor(Theme.Colors.textPrimary)
                                    .autocorrectionDisabled()
                                    .textInputAutocapitalization(.never)
                                
                                if !searchText.isEmpty {
                                    Button(action: { searchText = "" }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 14))
                                            .foregroundColor(Theme.Colors.textMuted)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(Theme.Colors.surfaceSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(Theme.Colors.dividerSubtle, lineWidth: 1)
                            )
                            
                            // Recent-5 / Filtered Selection Chips
                            if displayedIndividuals.isEmpty {
                                Text("No individuals found matching \"\(searchText)\"")
                                    .font(Theme.Typography.poppins(.regular, size: 13))
                                    .foregroundColor(Theme.Colors.textSecondary)
                                    .padding(.vertical, 8)
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(displayedIndividuals, id: \.self) { name in
                                            let isSelected = (selectedIndividual == name)
                                            Button(action: {
                                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                                    selectedIndividual = name
                                                }
                                            }) {
                                                Text(name)
                                                    .font(Theme.Typography.poppins(isSelected ? .bold : .medium, size: 13.5))
                                                    .foregroundColor(isSelected ? .white : Theme.Colors.textPrimary)
                                                    .padding(.horizontal, 16)
                                                    .padding(.vertical, 8)
                                                    .background(isSelected ? Theme.Colors.primary : Theme.Colors.surfaceSecondary)
                                                    .clipShape(Capsule())
                                                    .overlay(
                                                        Capsule()
                                                            .stroke(isSelected ? Color.clear : Theme.Colors.dividerSubtle, lineWidth: 1)
                                                    )
                                                    .shadow(color: isSelected ? Theme.Colors.primary.opacity(0.25) : Color.clear, radius: 4, x: 0, y: 2)
                                            }
                                            .buttonStyle(.plain)
                                            .accessibilityLabel(name)
                                            .accessibilityAddTraits(isSelected ? [.isSelected] : [])
                                        }
                                    }
                                    .padding(.vertical, 2)
                                }
                            }
                            
                            // Selected Individual's Score Band Chart
                            let currentPerson = selectedIndividual ?? displayedIndividuals.first ?? "Sarah Mitchell"
                            IndividualScoreBandChart(
                                dates: ["3/15", "4/02", "4/18", "5/02", "5/16", "5/25", "5/29"],
                                scores: scoresForIndividual(currentPerson)
                            )
                            .padding(.top, 6)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
        .background(Theme.Colors.background)
        .task {
            savedHistory = (try? await appEnvironment.assessmentRepo.fetchAssessmentHistory()) ?? []
            if selectedIndividual == nil {
                selectedIndividual = displayedIndividuals.first ?? "Sarah Mitchell"
            }
        }
    }
    
    private func scoresForIndividual(_ name: String) -> [CGFloat] {
        switch name {
        case "Sarah Mitchell":
            return [22, 31, 44, 52, 59, 74, 83]
        case "James Rivera", "James Cooper":
            return [48, 52, 58, 62, 65, 70, 75]
        case "Emily Chen":
            return [35, 40, 42, 48, 50, 56, 62]
        case "David Thompson":
            return [72, 75, 78, 80, 82, 85, 88]
        case "Anya Patel":
            return [60, 64, 68, 72, 75, 78, 81]
        default:
            return [45, 50, 55, 60, 68, 72, 79]
        }
    }
}

// MARK: - C.A.R.E. Results Multi-Line Trend Chart (4 Lines: Calm, Accepted, Resonant, Energetic)
public struct CARETrendChart: View {
    // 7 Historical Assessment Dates (3 visible at a time in viewport)
    private let dates = ["3/15", "4/02", "4/18", "5/02", "5/16", "5/25", "5/29"]
    
    // Y-Axis Labels: 100%, 75%, 50%, 25%, 0%
    private let yLabels = ["100%", "75%", "50%", "25%", "0%"]
    
    // 4 C.A.R.E. Data series (values 0.0 to 1.0)
    // Calm (Blue): 50% -> 55% -> 62% -> 68% -> 72% -> 80% -> 85%
    private let calmPoints: [CGFloat] = [0.50, 0.55, 0.62, 0.68, 0.72, 0.80, 0.85]
    // Accepted (Green): 45% -> 50% -> 55% -> 60% -> 68% -> 75% -> 80%
    private let acceptedPoints: [CGFloat] = [0.45, 0.50, 0.55, 0.60, 0.68, 0.75, 0.80]
    // Resonant (Amber): 40% -> 42% -> 48% -> 52% -> 58% -> 65% -> 72%
    private let resonantPoints: [CGFloat] = [0.40, 0.42, 0.48, 0.52, 0.58, 0.65, 0.72]
    // Energetic (Coral/Red): 35% -> 38% -> 45% -> 50% -> 55% -> 60% -> 68%
    private let energeticPoints: [CGFloat] = [0.35, 0.38, 0.45, 0.50, 0.55, 0.60, 0.68]
    
    private let chartHeight: CGFloat = 160
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 14) {
            // Main Chart Canvas with Fixed Y-Axis and Horizontally Scrollable Plot
            HStack(alignment: .top, spacing: 8) {
                // Fixed Y-Axis Labels
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
                .frame(width: 36, height: chartHeight)
                
                // Horizontally Scrollable Chart Plot Area
                GeometryReader { geo in
                    let viewportWidth = geo.size.width
                    let stepWidth = max(viewportWidth / 3.0, 75) // Exactly 3 dates visible per screen width
                    let totalWidth = stepWidth * CGFloat(dates.count)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 0) {
                            ZStack(alignment: .bottomLeading) {
                                // Horizontal Grid Lines spanning entire scroll width
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
                                .frame(width: totalWidth, height: chartHeight)
                                
                                // Bottom X-Axis line
                                Rectangle()
                                    .fill(Theme.Colors.textSecondary.opacity(0.3))
                                    .frame(width: totalWidth, height: 1)
                                    .frame(maxHeight: .infinity, alignment: .bottom)
                                
                                // Computed X coordinates for each point column
                                let xCoords = (0..<dates.count).map { stepWidth * (CGFloat($0) + 0.5) }
                                
                                // 1. Calm Line (Blue)
                                connectedLinePath(xCoords: xCoords, values: calmPoints, height: chartHeight)
                                    .stroke(Theme.Colors.Domains.calm, lineWidth: 2.5)
                                trendPointsView(xCoords: xCoords, values: calmPoints, height: chartHeight, color: Theme.Colors.Domains.calm)
                                
                                // 2. Accepted Line (Green)
                                connectedLinePath(xCoords: xCoords, values: acceptedPoints, height: chartHeight)
                                    .stroke(Theme.Colors.Domains.accepted, lineWidth: 2.5)
                                trendPointsView(xCoords: xCoords, values: acceptedPoints, height: chartHeight, color: Theme.Colors.Domains.accepted)
                                
                                // 3. Resonant Line (Amber)
                                connectedLinePath(xCoords: xCoords, values: resonantPoints, height: chartHeight)
                                    .stroke(Theme.Colors.Domains.resonant, lineWidth: 2.5)
                                trendPointsView(xCoords: xCoords, values: resonantPoints, height: chartHeight, color: Theme.Colors.Domains.resonant)
                                
                                // 4. Energetic Line (Coral/Red)
                                connectedLinePath(xCoords: xCoords, values: energeticPoints, height: chartHeight)
                                    .stroke(Theme.Colors.Domains.energetic, lineWidth: 2.5)
                                trendPointsView(xCoords: xCoords, values: energeticPoints, height: chartHeight, color: Theme.Colors.Domains.energetic)
                            }
                            .frame(width: totalWidth, height: chartHeight)
                            
                            // X-Axis Date Labels aligned with each point column
                            HStack(spacing: 0) {
                                ForEach(0..<dates.count, id: \.self) { idx in
                                    Text(dates[idx])
                                        .font(Theme.Typography.poppins(.regular, size: 11))
                                        .foregroundColor(Theme.Colors.textSecondary)
                                        .frame(width: stepWidth, alignment: .center)
                                }
                            }
                            .frame(width: totalWidth)
                            .padding(.top, 6)
                        }
                    }
                }
                .frame(height: chartHeight + 24)
            }
            
            // Legend Row: Calm, Accepted, Resonant, Energetic + Info Icon
            HStack(spacing: 8) {
                HStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Theme.Colors.Domains.calm)
                        .frame(width: 8, height: 8)
                    Text("Calm")
                        .font(Theme.Typography.poppins(.medium, size: 11))
                        .foregroundColor(Theme.Colors.textSecondary)
                        .lineLimit(1)
                }
                
                HStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Theme.Colors.Domains.accepted)
                        .frame(width: 8, height: 8)
                    Text("Accepted")
                        .font(Theme.Typography.poppins(.medium, size: 11))
                        .foregroundColor(Theme.Colors.textSecondary)
                        .lineLimit(1)
                }
                
                HStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Theme.Colors.Domains.resonant)
                        .frame(width: 8, height: 8)
                    Text("Resonant")
                        .font(Theme.Typography.poppins(.medium, size: 11))
                        .foregroundColor(Theme.Colors.textSecondary)
                        .lineLimit(1)
                }
                
                HStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Theme.Colors.Domains.energetic)
                        .frame(width: 8, height: 8)
                    Text("Energetic")
                        .font(Theme.Typography.poppins(.medium, size: 11))
                        .foregroundColor(Theme.Colors.textSecondary)
                        .lineLimit(1)
                }
                
                Spacer(minLength: 2)
                
                Image(systemName: "info.circle")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Theme.Colors.primary)
            }
            .padding(.top, 4)
        }
    }
    
    private func connectedLinePath(xCoords: [CGFloat], values: [CGFloat], height: CGFloat) -> Path {
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

// MARK: - Relational Safety Multi-Line Trend Chart (Figma Frame 95:2 with Horizontal Scroll)
public struct RelationalSafetyTrendChart: View {
    // 7 Historical Assessment Dates (3 visible at a time in viewport)
    private let dates = ["3/15", "4/02", "4/18", "5/02", "5/16", "5/25", "5/29"]
    
    // Y-Axis Labels: 100%, 75%, 50%, 25%, 0%
    private let yLabels = ["100%", "75%", "50%", "25%", "0%"]
    
    // Data series (values 0.0 to 1.0)
    // Safe (Green): 35% -> 40% -> 50% -> 55% -> 60% -> 75% -> 85%
    private let safePoints: [CGFloat] = [0.35, 0.40, 0.50, 0.55, 0.60, 0.75, 0.85]
    // Moderate (Yellow): 45% -> 40% -> 35% -> 30% -> 30% -> 20% -> 10%
    private let moderatePoints: [CGFloat] = [0.45, 0.40, 0.35, 0.30, 0.30, 0.20, 0.10]
    // High Risk (Coral): 20% -> 20% -> 15% -> 15% -> 10% -> 05% -> 05%
    private let highRiskPoints: [CGFloat] = [0.20, 0.20, 0.15, 0.15, 0.10, 0.05, 0.05]
    
    private let chartHeight: CGFloat = 160
    
    public var body: some View {
        VStack(spacing: 14) {
            // Main Chart Canvas with Fixed Y-Axis and Horizontally Scrollable Plot
            HStack(alignment: .top, spacing: 8) {
                // Fixed Y-Axis Labels
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
                .frame(width: 36, height: chartHeight)
                
                // Horizontally Scrollable Chart Plot Area
                GeometryReader { geo in
                    let viewportWidth = geo.size.width
                    let stepWidth = max(viewportWidth / 3.0, 75) // Exactly 3 dates visible per screen width
                    let totalWidth = stepWidth * CGFloat(dates.count)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 0) {
                            ZStack(alignment: .bottomLeading) {
                                // Horizontal Grid Lines spanning entire scroll width
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
                                .frame(width: totalWidth, height: chartHeight)
                                
                                // Bottom X-Axis line
                                Rectangle()
                                    .fill(Theme.Colors.textSecondary.opacity(0.3))
                                    .frame(width: totalWidth, height: 1)
                                    .frame(maxHeight: .infinity, alignment: .bottom)
                                
                                // Computed X coordinates for each point column
                                let xCoords = (0..<dates.count).map { stepWidth * (CGFloat($0) + 0.5) }
                                
                                // 1. Safe Line (Green) - Connecting adjacent dots
                                connectedLinePath(xCoords: xCoords, values: safePoints, height: chartHeight)
                                    .stroke(Theme.Colors.Safety.lowRisk, lineWidth: 2.5)
                                
                                trendPointsView(xCoords: xCoords, values: safePoints, height: chartHeight, color: Theme.Colors.Safety.lowRisk)
                                
                                // 2. Moderate Line (Yellow) - Connecting adjacent dots
                                connectedLinePath(xCoords: xCoords, values: moderatePoints, height: chartHeight)
                                    .stroke(Theme.Colors.Safety.moderateRisk, lineWidth: 2.5)
                                
                                trendPointsView(xCoords: xCoords, values: moderatePoints, height: chartHeight, color: Theme.Colors.Safety.moderateRisk)
                                
                                // 3. High Risk Line (Red/Coral) - Connecting adjacent dots
                                connectedLinePath(xCoords: xCoords, values: highRiskPoints, height: chartHeight)
                                    .stroke(Theme.Colors.Safety.highRisk, lineWidth: 2.5)
                                
                                trendPointsView(xCoords: xCoords, values: highRiskPoints, height: chartHeight, color: Theme.Colors.Safety.highRisk)
                            }
                            .frame(width: totalWidth, height: chartHeight)
                            
                            // X-Axis Date Labels aligned with each point column
                            HStack(spacing: 0) {
                                ForEach(0..<dates.count, id: \.self) { idx in
                                    Text(dates[idx])
                                        .font(Theme.Typography.poppins(.regular, size: 11))
                                        .foregroundColor(Theme.Colors.textSecondary)
                                        .frame(width: stepWidth, alignment: .center)
                                }
                            }
                            .frame(width: totalWidth)
                            .padding(.top, 6)
                        }
                    }
                }
                .frame(height: chartHeight + 24)
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
    
    /// Straight line segments connecting adjacent points directly
    private func connectedLinePath(xCoords: [CGFloat], values: [CGFloat], height: CGFloat) -> Path {
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

// MARK: - Individual Score 3-Tier Colored Band Chart (Figma Frame 95:2 with Horizontal Scroll & Connected Adjacent Dots)
public struct IndividualScoreBandChart: View {
    // Y-Axis: 100, 67, 33, 0
    private let yLabels = ["100", "67", "33", "0"]
    
    // 7 Historical Assessment Scores & Dates (3 visible at a time in viewport)
    public var dates: [String] = ["3/15", "4/02", "4/18", "5/02", "5/16", "5/25", "5/29"]
    public var scores: [CGFloat] = [22, 31, 44, 52, 59, 74, 83]
    
    private let chartHeight: CGFloat = 160
    
    public init(
        dates: [String] = ["3/15", "4/02", "4/18", "5/02", "5/16", "5/25", "5/29"],
        scores: [CGFloat] = [22, 31, 44, 52, 59, 74, 83]
    ) {
        self.dates = dates
        self.scores = scores
    }
    
    public var body: some View {
        VStack(spacing: 14) {
            HStack(alignment: .top, spacing: 8) {
                // Fixed Y-Axis Labels
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
                .frame(width: 26, height: chartHeight)
                
                // Horizontally Scrollable Band Chart Plot Area
                GeometryReader { geo in
                    let viewportWidth = geo.size.width
                    let stepWidth = max(viewportWidth / 3.0, 75) // Exactly 3 points visible per screen width
                    let totalWidth = stepWidth * CGFloat(dates.count)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 0) {
                            ZStack(alignment: .bottomLeading) {
                                // 3 Horizontal Colored Background Bands spanning entire scroll width
                                VStack(spacing: 0) {
                                    // Top Band: Safe (#D1F2D9 / Light Green)
                                    Rectangle()
                                        .fill(Color(red: 0.82, green: 0.94, blue: 0.85))
                                        .frame(height: chartHeight / 3.0)
                                    
                                    // Middle Band: Moderate (#FDF0D0 / Light Amber)
                                    Rectangle()
                                        .fill(Color(red: 0.99, green: 0.94, blue: 0.82))
                                        .frame(height: chartHeight / 3.0)
                                    
                                    // Bottom Band: High Risk (#FCDAD7 / Light Pink)
                                    Rectangle()
                                        .fill(Color(red: 0.98, green: 0.85, blue: 0.84))
                                        .frame(height: chartHeight / 3.0)
                                }
                                .frame(width: totalWidth, height: chartHeight)
                                
                                // Horizontal Dividers across bands
                                VStack(spacing: 0) {
                                    Rectangle().fill(Theme.Colors.textSecondary.opacity(0.3)).frame(height: 1)
                                    Spacer()
                                    Rectangle().fill(Theme.Colors.textSecondary.opacity(0.3)).frame(height: 1)
                                    Spacer()
                                    Rectangle().fill(Theme.Colors.textSecondary.opacity(0.3)).frame(height: 1)
                                    Spacer()
                                    Rectangle().fill(Theme.Colors.textSecondary.opacity(0.3)).frame(height: 1)
                                }
                                .frame(width: totalWidth, height: chartHeight)
                                
                                // Computed X coordinates for each point column
                                let xCoords = (0..<dates.count).map { stepWidth * (CGFloat($0) + 0.5) }
                                
                                // Straight line segments connecting adjacent dots directly
                                connectedScoreLinePath(xCoords: xCoords, scores: scores, height: chartHeight)
                                    .stroke(Color(red: 0.22, green: 0.55, blue: 0.78), lineWidth: 2.5)
                                
                                // Data Point Markers & Numeric Value Callouts
                                ForEach(0..<scores.count, id: \.self) { idx in
                                    let px = xCoords[idx]
                                    let py = chartHeight * (1.0 - (scores[idx] / 100.0))
                                    
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
                            .frame(width: totalWidth, height: chartHeight)
                            .clipShape(Rectangle())
                            
                            // X-Axis Date Labels aligned with each point column
                            HStack(spacing: 0) {
                                ForEach(0..<dates.count, id: \.self) { idx in
                                    Text(dates[idx])
                                        .font(Theme.Typography.poppins(.regular, size: 11))
                                        .foregroundColor(Theme.Colors.textSecondary)
                                        .frame(width: stepWidth, alignment: .center)
                                }
                            }
                            .frame(width: totalWidth)
                            .padding(.top, 6)
                        }
                    }
                }
                .frame(height: chartHeight + 24)
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
    
    /// Straight line segments connecting adjacent dots directly
    private func connectedScoreLinePath(xCoords: [CGFloat], scores: [CGFloat], height: CGFloat) -> Path {
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
