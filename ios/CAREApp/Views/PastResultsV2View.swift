import SwiftUI

// MARK: - Past Results V2 (Figma Frame 335:4)
public struct PastResultsV2View: View {
    @Environment(AppRouter.self) private var router: AppRouter?
    @Environment(AppEnvironment.self) private var appEnvironment
    public let recentResult: AssessmentResult?

    @State private var history: [AssessmentResult] = []
    @State private var searchText = ""
    @State private var selectedSortOption: RelationshipSortOption = .mostRecent
    @State private var isShowingSortSheet = false
    @State private var selectedCategory: CAREDomain = .calm
    @State private var selectedPersonID: UUID?

    public init(recentResult: AssessmentResult? = nil) {
        self.recentResult = recentResult
    }

    private var chronologicalHistory: [AssessmentResult] {
        history.sorted { $0.timestamp < $1.timestamp }
    }

    private var latest: AssessmentResult? { chronologicalHistory.last }

    private var latestPeople: [IndividualResult] {
        var seen = Set<UUID>()
        let people = chronologicalHistory.reversed().flatMap(\.individualResults).filter {
            seen.insert($0.id).inserted
        }
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let filtered = query.isEmpty ? people : people.filter {
            $0.participant.person.name.localizedCaseInsensitiveContains(query)
        }
        switch selectedSortOption {
        case .mostRecent: return filtered
        case .mostCompleted:
            return filtered.sorted { personHistoryCount($0.id) > personHistoryCount($1.id) }
        case .highestScore:
            return filtered.sorted { $0.normalizedScore > $1.normalizedScore }
        }
    }

    private func personHistoryCount(_ id: UUID) -> Int {
        chronologicalHistory.filter { $0.individualResults.contains { $0.id == id } }.count
    }

    private func personHistory(_ id: UUID) -> [(Date, Double)] {
        chronologicalHistory.compactMap { result in
            guard let person = result.individualResults.first(where: { $0.id == id }) else { return nil }
            return (result.timestamp, person.normalizedScore)
        }
    }

    public var body: some View {
        VStack(spacing: 0) {
            HeaderNavBar(
                showBackButton: true,
                showHomeButton: true,
                showSparkleButton: true,
                showChartButton: false,
                showProfileButton: true,
                onBack: { router?.pop() }
            )

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("ASSESSMENT HISTORY")
                            .font(Theme.Typography.poppins(.bold, size: 11))
                            .foregroundColor(Theme.Colors.primary)
                            .tracking(1)
                        Text("Past Results")
                            .font(Theme.Typography.screenTitle)
                            .foregroundColor(Theme.Colors.textPrimary)
                        Text("Compare results across your C.A.R.E. assessments")
                            .font(Theme.Typography.screenSubtitle)
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                    .padding(.top, Theme.Spacing.headerTitleSpacing)
                    .padding(.bottom, 4)

                    if history.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("No assessments yet")
                                .font(Theme.Typography.poppins(.bold, size: 20))
                            Text("Complete your first assessment to see scores and relationship trends here.")
                                .font(Theme.Typography.poppins(.regular, size: 14))
                                .foregroundStyle(Theme.Colors.textSecondary)
                            PrimaryButton(title: "Start Assessment") { router?.navigate(to: .assessmentOverview) }
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Theme.Colors.cardSurface, in: RoundedRectangle(cornerRadius: 20))
                    } else {
                        totalScoreCard
                        categoryDetailsCard
                        relationalSafetyCard
                        relationshipBreakdownCard
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }

            VStack(spacing: 6) {
                SecondaryButton(title: "Return to Home", icon: "arrow.left") {
                    router?.popToRoot()
                }
                Text("Your plan updates as you grow. Retake assessment anytime.")
                    .font(Theme.Typography.poppins(.regular, size: 11))
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.white.ignoresSafeArea(edges: .bottom))
        }
        .background(Color(hex: "#F8FAFC").ignoresSafeArea())
        .sheet(isPresented: $isShowingSortSheet) {
            RelationshipSortSheet(
                selectedOption: $selectedSortOption,
                onApply: { _ in isShowingSortSheet = false },
                onCancel: { isShowingSortSheet = false }
            )
        }
        .onChange(of: searchText) { _, _ in
            selectedPersonID = latestPeople.first?.id
        }
        .task {
            history = (try? await appEnvironment.assessmentRepo.fetchAssessmentHistory()) ?? []
            if let recentResult, !history.contains(where: { $0.id == recentResult.id }) {
                history.insert(recentResult, at: 0)
            }
            selectedPersonID = latestPeople.first?.id
        }
    }

    private var totalScoreCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Total Score Trends")
                    .font(Theme.Typography.poppins(.bold, size: 16))
                    .foregroundColor(Theme.Colors.textPrimary)
                Spacer()
                Text("OVERALL")
                    .font(Theme.Typography.poppins(.bold, size: 10))
                    .foregroundColor(.white)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(Theme.Colors.primary)
                    .clipShape(Capsule())
            }

            Text("Tap a point to view that assessment’s full results.")
                .font(Theme.Typography.callout)
                .foregroundColor(Theme.Colors.textSecondary)

            HStack(alignment: .top) {
                scoreSummary(
                    label: "LATEST",
                    value: latest.map { "\(Int(ResultsV2Metrics.totalScore($0).rounded()))/\(Int(ResultsV2Metrics.totalMaximum($0).rounded()))" } ?? "—/500",
                    detail: changeFromPrevious
                )
                Spacer()
                scoreSummary(
                    label: "PEAK SCORE",
                    value: peakResult.map { "\(Int(ResultsV2Metrics.totalScore($0).rounded()))/\(Int(ResultsV2Metrics.totalMaximum($0).rounded()))" } ?? "—/500",
                    detail: peakDate
                )
            }

            ResultsV2TrendChart(
                dates: chronologicalHistory.map(\.timestamp),
                series: [
                    ResultsV2TrendSeries(
                        color: Theme.Colors.primary,
                        values: chronologicalHistory.map(totalPercentage)
                    )
                ],
                maximum: 100,
                height: 140,
                interactivePoints: ResultsV2TrendPoint.from(chronologicalHistory),
                onPointTap: { router?.navigate(to: .historicalSurveyResults($0)) }
            )
        }
        .padding(16)
        .background(Color(hex: "#E1EFFE"))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var changeFromPrevious: String {
        guard chronologicalHistory.count >= 2 else { return "First assessment" }
        let previous = totalPercentage(chronologicalHistory[chronologicalHistory.count - 2])
        let current = totalPercentage(chronologicalHistory.last!)
        guard previous > 0 else { return "First assessment" }
        let change = (current - previous) / previous * 100
        return String(format: "%+.0f%% vs last", change)
    }

    private var peakDate: String {
        guard let peak = peakResult else { return "No results yet" }
        return "On \(peak.timestamp.formatted(.dateTime.month(.abbreviated).day()))"
    }

    private func totalPercentage(_ result: AssessmentResult) -> Double {
        let maximum = ResultsV2Metrics.totalMaximum(result)
        return maximum > 0 ? ResultsV2Metrics.totalScore(result) / maximum * 100 : 0
    }

    private var peakResult: AssessmentResult? {
        chronologicalHistory.max { totalPercentage($0) < totalPercentage($1) }
    }

    private func scoreSummary(label: String, value: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(Theme.Typography.poppins(.medium, size: 10))
                .foregroundColor(Theme.Colors.textSecondary)
            Text(value)
                .font(Theme.Typography.poppins(.bold, size: 20))
                .foregroundColor(Theme.Colors.textPrimary)
            Text(detail)
                .font(Theme.Typography.poppins(.medium, size: 11))
                .foregroundColor(Color(hex: "#2D9F7F"))
        }
    }

    private var categoryDetailsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("C.A.R.E. Category Details", route: .careInfo)

            ForEach(CAREDomain.allCases, id: \.self) { domain in
                let score = latest.map { ResultsV2Metrics.score($0, for: domain) } ?? 0
                Button {
                    selectedCategory = domain
                } label: {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(ResultsV2Palette.donutColor(for: domain))
                            .frame(width: 8, height: 8)
                        Text(domain.title)
                            .font(Theme.Typography.poppins(.semiBold, size: 13))
                            .foregroundColor(Theme.Colors.textPrimary)
                        Spacer()
                        Text("\(Int(score.rounded()))/\(Int(latest.map { ResultsV2Metrics.maximum($0, for: domain) } ?? 125))")
                            .font(Theme.Typography.poppins(.bold, size: 13))
                            .foregroundColor(ResultsV2Palette.labelColor(for: domain))
                        Image(systemName: selectedCategory == domain ? "chevron.down" : "chevron.right")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                }
                .buttonStyle(.plain)

                if selectedCategory == domain {
                    ResultsV2TrendChart(
                        dates: chronologicalHistory.map(\.timestamp),
                        series: [
                            ResultsV2TrendSeries(
                                color: ResultsV2Palette.labelColor(for: domain),
                                values: chronologicalHistory.map { ResultsV2Metrics.percentage($0, for: domain) }
                            )
                        ],
                        maximum: 100,
                        height: 125,
                        showScoreBands: true
                    )
                    .padding(.bottom, 6)
                }

                if domain != CAREDomain.allCases.last {
                    Divider().background(Theme.Colors.dividerSubtle)
                }
            }
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Theme.Colors.dividerSubtle, lineWidth: 1))
    }

    private var relationalSafetyCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Relational Safety", route: .surveyResultsExpanded)
            ResultsV2TrendChart(
                dates: chronologicalHistory.map(\.timestamp),
                series: [
                    ResultsV2TrendSeries(color: ResultsV2Palette.safe, values: chronologicalHistory.map { $0.safetyDistribution.safePercentage * 100 }),
                    ResultsV2TrendSeries(color: ResultsV2Palette.moderate, values: chronologicalHistory.map { $0.safetyDistribution.moderatePercentage * 100 }),
                    ResultsV2TrendSeries(color: ResultsV2Palette.highRisk, values: chronologicalHistory.map { $0.safetyDistribution.highRiskPercentage * 100 })
                ],
                maximum: 100,
                height: 145
            )
            HStack(spacing: 12) {
                legend("Safe", color: ResultsV2Palette.safe)
                legend("Moderate", color: ResultsV2Palette.moderate)
                legend("High Risk", color: ResultsV2Palette.highRisk)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Theme.Colors.dividerSubtle, lineWidth: 1))
    }

    private var relationshipBreakdownCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Relationship Breakdown", route: .surveyResultsExpanded)
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Theme.Colors.textSecondary)
                TextField("Search relationships...", text: $searchText)
                    .font(Theme.Typography.poppins(.regular, size: 13))
                    .autocorrectionDisabled()
                Button {
                    isShowingSortSheet = true
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundColor(Theme.Colors.primary)
                }
                .accessibilityLabel("Sort relationships")
            }
            .padding(10)
            .background(Color(hex: "#F1F5F9"))
            .clipShape(RoundedRectangle(cornerRadius: 10))

            if latestPeople.isEmpty {
                Text("No relationships found")
                    .font(Theme.Typography.poppins(.regular, size: 13))
                    .foregroundColor(Theme.Colors.textSecondary)
            }

            ForEach(latestPeople) { person in
                VStack(alignment: .leading, spacing: 8) {
                    Button {
                        selectedPersonID = person.id
                    } label: {
                        HStack {
                            Text(person.participant.person.name)
                                .font(Theme.Typography.poppins(.semiBold, size: 13))
                                .foregroundColor(Theme.Colors.textPrimary)
                            Spacer()
                            Text("\(Int(person.normalizedScore.rounded()))")
                                .font(Theme.Typography.poppins(.bold, size: 12))
                                .foregroundColor(Theme.Colors.textPrimary)
                            Image(systemName: selectedPersonID == person.id ? "chevron.down" : "chevron.right")
                                .font(.system(size: 11))
                                .foregroundColor(Theme.Colors.textSecondary)
                        }
                    }
                    .buttonStyle(.plain)

                    if selectedPersonID == person.id {
                        let points = personHistory(person.id)
                        ResultsV2TrendChart(
                            dates: points.map(\.0),
                            series: [ResultsV2TrendSeries(color: Theme.Colors.primary, values: points.map(\.1))],
                            maximum: 100,
                            height: 125,
                            showScoreBands: true
                        )
                    }
                }
                if person.id != latestPeople.last?.id {
                    Divider().background(Theme.Colors.dividerSubtle)
                }
            }
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Theme.Colors.dividerSubtle, lineWidth: 1))
    }

    private func sectionHeader(_ title: String, route: AppRoute) -> some View {
        HStack {
            Text(title)
                .font(Theme.Typography.poppins(.bold, size: 16))
                .foregroundColor(Theme.Colors.textPrimary)
            Spacer()
            Button {
                router?.navigate(to: route)
            } label: {
                Image(systemName: "info.circle")
                    .font(.system(size: 17))
                    .foregroundColor(Theme.Colors.primary)
            }
            .accessibilityLabel("About \(title)")
        }
    }

    private func legend(_ title: String, color: Color) -> some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 2).fill(color).frame(width: 8, height: 8)
            Text(title)
                .font(Theme.Typography.poppins(.regular, size: 10))
                .foregroundColor(Theme.Colors.textSecondary)
        }
    }
}

struct ResultsV2TrendSeries {
    let color: Color
    let values: [Double]
}

struct ResultsV2TrendPoint: Identifiable {
    let resultID: UUID
    let date: Date
    let percentage: Double
    var id: UUID { resultID }

    static func from(_ results: [AssessmentResult]) -> [Self] {
        results.map { result in
            let maximum = ResultsV2Metrics.totalMaximum(result)
            let percentage = maximum > 0 ? ResultsV2Metrics.totalScore(result) / maximum * 100 : 0
            return Self(resultID: result.id, date: result.timestamp, percentage: percentage)
        }
    }
}

// Drawn from assessment history, with the Figma card's grid and score bands.
struct ResultsV2TrendChart: View {
    static func requiredInteractiveWidth(pointCount: Int) -> CGFloat {
        max(280, CGFloat(max(pointCount - 1, 0)) * 52 + 32)
    }

    let dates: [Date]
    let series: [ResultsV2TrendSeries]
    let maximum: Double
    let height: CGFloat
    var showScoreBands = false
    var interactivePoints: [ResultsV2TrendPoint] = []
    var onPointTap: ((UUID) -> Void)? = nil

    var body: some View {
        Group {
            if interactivePoints.isEmpty {
                chartContent
            } else {
                NoHorizontalBounceScrollView(showsIndicators: true) {
                    chartContent
                        .frame(width: Self.requiredInteractiveWidth(pointCount: interactivePoints.count))
                }
                .defaultScrollAnchor(.trailing)
                .accessibilityHint("Scroll horizontally to reach older assessment points")
            }
        }
    }

    private var chartContent: some View {
        VStack(spacing: 4) {
            Canvas { context, size in
                let plot = CGRect(x: 26, y: 8, width: max(size.width - 32, 1), height: max(size.height - 18, 1))

                if showScoreBands {
                    context.fill(Path(CGRect(x: plot.minX, y: plot.minY, width: plot.width, height: plot.height * 0.25)), with: .color(Color(hex: "#EAF8F0")))
                    context.fill(Path(CGRect(x: plot.minX, y: plot.minY + plot.height * 0.25, width: plot.width, height: plot.height * 0.25)), with: .color(Color(hex: "#FFF7E3")))
                    context.fill(Path(CGRect(x: plot.minX, y: plot.minY + plot.height * 0.5, width: plot.width, height: plot.height * 0.5)), with: .color(Color(hex: "#FDECEE")))
                }

                for step in 0...4 {
                    let y = plot.minY + plot.height * CGFloat(step) / 4
                    var grid = Path()
                    grid.move(to: CGPoint(x: plot.minX, y: y))
                    grid.addLine(to: CGPoint(x: plot.maxX, y: y))
                    context.stroke(grid, with: .color(Theme.Colors.dividerSubtle), lineWidth: 0.7)
                    let label = Int(maximum * Double(4 - step) / 4)
                    context.draw(
                        Text("\(label)").font(.system(size: 8)).foregroundColor(Theme.Colors.textMuted),
                        at: CGPoint(x: 10, y: y)
                    )
                }

                for item in series {
                    guard !item.values.isEmpty else { continue }
                    var line = Path()
                    for (index, value) in item.values.enumerated() {
                        let x = plot.minX + (item.values.count == 1
                            ? plot.width / 2
                            : plot.width * CGFloat(index) / CGFloat(item.values.count - 1))
                        let y = plot.maxY - plot.height * CGFloat(min(max(value / maximum, 0), 1))
                        let point = CGPoint(x: x, y: y)
                        if index == 0 { line.move(to: point) } else { line.addLine(to: point) }
                        context.fill(Path(ellipseIn: CGRect(x: x - 3, y: y - 3, width: 6, height: 6)), with: .color(item.color))
                    }
                    context.stroke(line, with: .color(item.color), style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                }
            }
            .frame(height: height)
            .overlay {
                if let onPointTap, !interactivePoints.isEmpty {
                    GeometryReader { geometry in
                        let plot = CGRect(x: 26, y: 8, width: max(geometry.size.width - 32, 1), height: max(geometry.size.height - 18, 1))
                        ForEach(Array(interactivePoints.enumerated()), id: \.element.id) { index, point in
                            let x = plot.minX + (interactivePoints.count == 1
                                ? plot.width / 2
                                : plot.width * CGFloat(index) / CGFloat(interactivePoints.count - 1))
                            let y = plot.maxY - plot.height * CGFloat(min(max(point.percentage / maximum, 0), 1))
                            Button {
                                onPointTap(point.resultID)
                            } label: {
                                Circle().fill(Color.white.opacity(0.001)).frame(width: 44, height: 44)
                            }
                            .buttonStyle(.plain)
                            .contentShape(Circle())
                            .position(x: x, y: y)
                            .accessibilityLabel("View assessment results from \(point.date.formatted(date: .abbreviated, time: .omitted))")
                        }
                    }
                }
            }

            HStack {
                ForEach(Array(dates.enumerated()), id: \.offset) { index, date in
                    Text(date.formatted(.dateTime.month(.twoDigits).day(.twoDigits)))
                        .font(Theme.Typography.poppins(.regular, size: 9))
                        .foregroundColor(Theme.Colors.textSecondary)
                    if index < dates.count - 1 { Spacer() }
                }
            }
            .padding(.leading, 26)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Assessment trend chart")
    }
}

#Preview {
    PastResultsV2View()
        .environment(AppRouter())
        .environment(AppEnvironment.preview)
}
