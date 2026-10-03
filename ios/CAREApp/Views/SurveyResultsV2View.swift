import SwiftUI

// MARK: - Screen: Survey Results V2 (Figma Frame 292:4 & Node 239:8)
public struct SurveyResultsV2View: View {
    @Environment(AppRouter.self) private var router: AppRouter?
    @Environment(AppEnvironment.self) private var appEnvironment: AppEnvironment?
    public let result: AssessmentResult
    
    @State private var searchText: String = ""
    @State private var expandedCategories: Set<String> = ["Calm"]
    @State private var selectedSortOption: RelationshipSortOption = .mostRecent
    @State private var isShowingSortSheet = false
    @State private var assessmentHistory: [AssessmentResult] = []
    
    public init(result: AssessmentResult) {
        self.result = result
    }

    private var scoreSegments: [DonutSegment] {
        ResultsV2Metrics.compositionSegments(result)
    }

    private var displayedPeople: [IndividualResult] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let people = query.isEmpty ? result.individualResults : result.individualResults.filter {
            $0.participant.person.name.localizedCaseInsensitiveContains(query)
        }
        switch selectedSortOption {
        case .mostRecent: return people
        case .mostCompleted: return people.sorted { completedAssessments(for: $0.id) > completedAssessments(for: $1.id) }
        case .highestScore: return people.sorted { $0.normalizedScore > $1.normalizedScore }
        }
    }

    private func completedAssessments(for personID: UUID) -> Int {
        let past = assessmentHistory.filter { $0.id != result.id }
        return 1 + past.filter { $0.individualResults.contains { $0.id == personID } }.count
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            HeaderNavBar(
                showBackButton: true,
                showHomeButton: true,
                showChartButton: true,
                showProfileButton: true,
                onBack: { router?.pop() }
            )
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Title Section
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Survey Results")
                            .font(Theme.Typography.screenTitle)
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        Text("Review insights and relational health metrics from your C.A.R.E. assessment.")
                            .font(Theme.Typography.screenSubtitle)
                            .foregroundColor(Theme.Colors.textSecondary)
                            .lineSpacing(2)
                    }
                    .padding(.top, Theme.Spacing.headerTitleSpacing)
                    
                    // Your C.A.R.E. Score Card with (i) Info Button
                    VStack(spacing: 16) {
                        HStack {
                            Text("Your C.A.R.E. Score")
                                .font(Theme.Typography.poppins(.bold, size: 16))
                                .foregroundColor(Theme.Colors.textPrimary)
                            
                            Spacer()
                            
                            Button(action: {
                                router?.navigate(to: .careInfo)
                            }) {
                                Image(systemName: "info.circle")
                                    .font(.system(size: 18))
                                    .foregroundColor(Theme.Colors.primary)
                            }
                            .buttonStyle(.plain)
                        }
                        
                        // Donut Summary
                        ZStack {
                            DonutChartView(
                                segments: scoreSegments,
                                diameter: 140,
                                strokeWidth: 24,
                                gapWidth: 4,
                                cornerRadius: 4
                            )
                            .frame(width: 140, height: 140)
                            
                            VStack(spacing: 1) {
                                Text("\(Int(ResultsV2Metrics.totalScore(result).rounded()))")
                                    .font(Theme.Typography.poppins(.bold, size: 28))
                                    .foregroundColor(Theme.Colors.textPrimary)
                                Text("out of \(Int(ResultsV2Metrics.totalMaximum(result).rounded()))")
                                    .font(Theme.Typography.poppins(.regular, size: 11))
                                    .foregroundColor(Theme.Colors.textSecondary)
                            }
                        }
                        .padding(.vertical, 8)
                        
                        // 4 Category Mini-Scores
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(CAREDomain.allCases, id: \.self) { domain in
                                scoreGridItem(
                                    label: domain.title,
                                    score: "\(Int(ResultsV2Metrics.score(result, for: domain).rounded()))/\(Int(ResultsV2Metrics.maximum(result, for: domain).rounded()))",
                                    color: ResultsV2Palette.donutColor(for: domain)
                                )
                            }
                        }
                    }
                    .padding(18)
                    .background(Color(hex: "#F0F5FD"))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color(hex: "#E2E8F0"), lineWidth: 1)
                    )
                    
                    // Category Breakdown Accordions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Category Breakdown")
                            .font(Theme.Typography.poppins(.bold, size: 18))
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        ForEach(CAREDomain.allCases, id: \.self) { domain in
                            let score = ResultsV2Metrics.score(result, for: domain)
                            let percentage = ResultsV2Metrics.percentage(result, for: domain)
                            categoryAccordion(
                                category: domain.title,
                                status: ResultsV2CategoryCopy.status(for: domain, score: percentage),
                                score: "\(Int(score.rounded())) / \(Int(ResultsV2Metrics.maximum(result, for: domain).rounded()))",
                                explanation: ResultsV2CategoryCopy.explanation(for: domain),
                                resultTag: "YOUR RESULT · \(ResultsV2CategoryCopy.tierTitle(for: domain, score: percentage))",
                                resultDetail: ResultsV2CategoryCopy.tierDescription(for: domain, score: percentage),
                                exerciseButtonTitle: "Explore \(domain.title) Exercises",
                                color: ResultsV2Palette.donutColor(for: domain),
                                accent: ResultsV2Palette.labelColor(for: domain),
                                exerciseRoute: ResultsV2CategoryCopy.exerciseRoute(for: domain)
                            )
                        }
                    }
                    
                    // Your Relationships Section
                    VStack(alignment: .leading, spacing: 14) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Your Relationships")
                                .font(Theme.Typography.poppins(.bold, size: 18))
                                .foregroundColor(Theme.Colors.textPrimary)
                            Text("See how your current relationships contribute to your overall sense of safety and connection.")
                                .font(Theme.Typography.poppins(.regular, size: 12.5))
                                .foregroundColor(Theme.Colors.textSecondary)
                        }
                        
                        // Relational Safety Summary Card with (i)
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Relational Safety")
                                    .font(Theme.Typography.poppins(.semiBold, size: 15))
                                    .foregroundColor(Theme.Colors.textPrimary)
                                Spacer()
                                Button(action: {
                                    router?.navigate(to: .surveyResultsExpanded)
                                }) {
                                    Image(systemName: "info.circle")
                                        .foregroundColor(Theme.Colors.primary)
                                }
                                .buttonStyle(.plain)
                            }
                            
                            HStack(spacing: 16) {
                                DonutChartView(
                                    segments: ResultsV2Metrics.safetySegments(result.safetyDistribution),
                                    diameter: 120,
                                    strokeWidth: 22,
                                    gapWidth: 4,
                                    cornerRadius: 4
                                )
                                VStack(alignment: .leading, spacing: 10) {
                                    safetyLegend("Safe", share: result.safetyDistribution.safePercentage, color: ResultsV2Palette.safe)
                                    safetyLegend("Moderate Risk", share: result.safetyDistribution.moderatePercentage, color: ResultsV2Palette.moderate)
                                    safetyLegend("High Risk", share: result.safetyDistribution.highRiskPercentage, color: ResultsV2Palette.highRisk)
                                }
                            }
                        }
                        .padding(14)
                        .background(Color.white)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(hex: "#E2E8F0"), lineWidth: 1)
                        )
                        
                        // Relationship Breakdown Swipable Card
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Relationship Breakdown")
                                    .font(Theme.Typography.poppins(.semiBold, size: 15))
                                    .foregroundColor(Theme.Colors.textPrimary)
                                Spacer()
                                Button {
                                    router?.navigate(to: .surveyResultsExpanded)
                                } label: {
                                    Image(systemName: "info.circle")
                                        .foregroundColor(Theme.Colors.primary)
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel("About relational risk groups")
                            }
                            
                            HStack(spacing: 8) {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(Theme.Colors.textSecondary)
                                TextField("Search relationships...", text: $searchText)
                                    .font(Theme.Typography.poppins(.regular, size: 13.5))
                                Button {
                                    isShowingSortSheet = true
                                } label: {
                                    Image(systemName: "slider.horizontal.3")
                                        .foregroundColor(Theme.Colors.primary)
                                }
                                .accessibilityLabel("Sort relationships")
                            }
                            .padding(.horizontal, 12)
                            .frame(height: 40)
                            .background(Color(hex: "#F1F5F9"))
                            .cornerRadius(10)
                            
                            VStack(spacing: 8) {
                                ForEach(displayedPeople) { person in
                                    personRow(
                                        initials: person.participant.person.initials,
                                        name: person.participant.person.name,
                                        score: "\(Int(person.normalizedScore.rounded()))/100",
                                        status: person.safetyTier.rawValue,
                                        statusColor: ResultsV2Palette.color(for: person.safetyTier)
                                    )
                                }
                            }
                        }
                        .padding(14)
                        .background(Color.white)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(hex: "#E2E8F0"), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            
            // Pinned Bottom Actions
            VStack(spacing: 10) {
                PrimaryButton(
                    title: "Explore Recommended Exercises",
                    action: {
                        router?.navigate(to: .careResultsExercises)
                    }
                )
                
                SecondaryButton(
                    title: "View Past Results",
                    icon: "chart.line.uptrend.xyaxis",
                    action: {
                        router?.navigate(to: .pastResults)
                    }
                )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.white.ignoresSafeArea(edges: .bottom))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "#F5F7FA").ignoresSafeArea())
        .sheet(isPresented: $isShowingSortSheet) {
            RelationshipSortSheet(
                selectedOption: $selectedSortOption,
                onApply: { _ in isShowingSortSheet = false },
                onCancel: { isShowingSortSheet = false }
            )
        }
        .task {
            assessmentHistory = (try? await appEnvironment?.assessmentRepo.fetchAssessmentHistory()) ?? []
        }
    }
    
    @ViewBuilder
    private func scoreGridItem(label: String, score: String, color: Color) -> some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 4, height: 20)
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(Theme.Typography.poppins(.medium, size: 12))
                    .foregroundColor(Theme.Colors.textSecondary)
                Text(score)
                    .font(Theme.Typography.poppins(.bold, size: 14))
                    .foregroundColor(Theme.Colors.textPrimary)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color(hex: "#F8FAFC"))
        .cornerRadius(10)
    }
    
    @ViewBuilder
    private func categoryAccordion(
        category: String,
        status: String,
        score: String,
        explanation: String,
        resultTag: String,
        resultDetail: String,
        exerciseButtonTitle: String,
        color: Color,
        accent: Color,
        exerciseRoute: AppRoute
    ) -> some View {
        let isExpanded = expandedCategories.contains(category)
        VStack(alignment: .leading, spacing: 10) {
            Button(action: {
                if isExpanded {
                    expandedCategories.remove(category)
                } else {
                    expandedCategories.insert(category)
                }
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text(category)
                                .font(Theme.Typography.poppins(.bold, size: 15))
                                .foregroundColor(Theme.Colors.textPrimary)
                        }
                        Text(status)
                            .font(Theme.Typography.poppins(.regular, size: 12))
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                    
                    Spacer()
                    
                    Text(score)
                        .font(Theme.Typography.poppins(.semiBold, size: 14))
                        .foregroundColor(Theme.Colors.textPrimary)
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Theme.Colors.textSecondary)
                }
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 10) {
                    Text(explanation)
                        .font(Theme.Typography.poppins(.regular, size: 13))
                        .foregroundColor(Theme.Colors.textSecondary)
                        .lineSpacing(2)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(resultTag)
                            .font(Theme.Typography.poppins(.bold, size: 11))
                            .foregroundColor(accent)
                        
                        Text(resultDetail)
                            .font(Theme.Typography.poppins(.regular, size: 12.5))
                            .foregroundColor(Theme.Colors.textSecondary)
                            .lineSpacing(2)
                    }
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(12)
                    
                    Button(action: {
                        router?.navigate(to: exerciseRoute)
                    }) {
                        HStack {
                            Text(exerciseButtonTitle)
                                .font(Theme.Typography.poppins(.semiBold, size: 13))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundColor(Theme.Colors.primary)
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 4)
            }
        }
        .padding(14)
        .background(Color(hex: "#F0F5FD"))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "#E2E8F0"), lineWidth: 1)
        )
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 4)
        }
    }
    
    private func safetyLegend(_ label: String, share: Double, color: Color) -> some View {
        HStack(spacing: 6) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text("\(Int((share * 100).rounded()))% \(label)")
                .font(Theme.Typography.poppins(.medium, size: 11))
                .foregroundColor(Theme.Colors.textPrimary)
        }
    }
    
    @ViewBuilder
    private func personRow(initials: String, name: String, score: String, status: String, statusColor: Color) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(Color.white).frame(width: 36, height: 36)
                Text(initials)
                    .font(Theme.Typography.poppins(.bold, size: 13))
                    .foregroundColor(Theme.Colors.primary)
            }
            
            Text(name)
                .font(Theme.Typography.poppins(.medium, size: 14))
                .foregroundColor(Theme.Colors.textPrimary)
            
            Spacer()
            
            Text(score)
                .font(Theme.Typography.poppins(.semiBold, size: 12))
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(statusColor)
                .clipShape(Capsule())
                .accessibilityLabel("\(score), \(status)")
        }
        .padding(10)
        .background(Color(hex: "#E1EFFE"))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.Colors.primary.opacity(0.28), lineWidth: 1))
    }
}

enum ResultsV2Palette {
    static let safe = Color(hex: "#38B969")
    static let moderate = Color(hex: "#FABF2E")
    static let highRisk = Color(hex: "#E84D4D")

    static func donutColor(for domain: CAREDomain) -> Color {
        domain.themeColor
    }

    static func labelColor(for domain: CAREDomain) -> Color {
        domain.accentColor
    }

    static func color(for tier: SafetyTier) -> Color {
        switch tier {
        case .healthy: return safe
        case .moderate: return moderate
        case .highRisk: return highRisk
        }
    }
}

enum ResultsV2Metrics {
    static func score(_ result: AssessmentResult, for domain: CAREDomain) -> Double {
        max(result.domainScores[domain]?.earnedPoints ?? 0, 0)
    }

    static func maximum(_ result: AssessmentResult, for domain: CAREDomain) -> Double {
        result.domainScores[domain]?.maxPossiblePoints ?? 125
    }

    static func percentage(_ result: AssessmentResult, for domain: CAREDomain) -> Double {
        guard let breakdown = result.domainScores[domain] else { return 0 }
        return min(max(breakdown.percentage * 100, 0), 100)
    }

    static func totalMaximum(_ result: AssessmentResult) -> Double {
        CAREDomain.allCases.reduce(0) { $0 + maximum(result, for: $1) }
    }

    static func totalScore(_ result: AssessmentResult) -> Double {
        CAREDomain.allCases.reduce(0) { $0 + score(result, for: $1) }
    }

    static func compositionSegments(_ result: AssessmentResult) -> [DonutSegment] {
        let total = totalScore(result)
        guard total > 0 else { return [] }
        return CAREDomain.allCases.map { domain in
            DonutSegment(
                title: domain.title,
                color: ResultsV2Palette.donutColor(for: domain),
                percentage: score(result, for: domain) / total
            )
        }
    }

    static func safetySegments(_ distribution: RelationalSafetyDistribution) -> [DonutSegment] {
        [
            DonutSegment(title: "Safe", color: ResultsV2Palette.safe, percentage: distribution.safePercentage),
            DonutSegment(title: "Moderate Risk", color: ResultsV2Palette.moderate, percentage: distribution.moderatePercentage),
            DonutSegment(title: "High Risk", color: ResultsV2Palette.highRisk, percentage: distribution.highRiskPercentage)
        ]
    }
}

enum ResultsV2CategoryCopy {
    private static func tier(for score: Double) -> Int {
        score >= 76 ? 0 : (score >= 56 ? 1 : 2)
    }

    static func status(for domain: CAREDomain, score: Double) -> String {
        switch (domain, tier(for: score)) {
        case (.calm, 0): return "Strong sense of calm and regulation"
        case (.calm, 1): return "Calm can vary across relationships"
        case (.calm, _): return "Relationships may feel stressful"
        case (.accepted, 0): return "A strong sense of belonging"
        case (.accepted, 1): return "Sometimes sensitive to exclusion"
        case (.accepted, _): return "Belonging may feel uncertain"
        case (.resonant, 0): return "Understanding comes easily"
        case (.resonant, 1): return "Understanding can take effort"
        case (.resonant, _): return "Feeling understood may be difficult"
        case (.energetic, 0): return "Connections feel rewarding"
        case (.energetic, 1): return "Connection is sometimes energizing"
        case (.energetic, _): return "Connection may feel draining"
        }
    }

    static func explanation(for domain: CAREDomain) -> String {
        switch domain {
        case .calm: return "Calmness is related to the functioning of the smart vagus nerve and your social engagement system."
        case .accepted: return "Acceptance reflects how safe and included you feel in your relationships. It measures your sense of belonging and how secure you feel with those around you."
        case .resonant: return "Resonance captures the depth of mutual understanding in your relationships. It reflects how well you and others truly get each other on an emotional level."
        case .energetic: return "Energy measures how much vitality and motivation you draw from your relationships. It reflects whether your connections leave you feeling energized or drained."
        }
    }

    static func tierTitle(for domain: CAREDomain, score: Double) -> String {
        let index = tier(for: score)
        switch domain {
        case .calm: return ["Good Vagal Tone", "Moderate Vagal Tone", "Low Vagal Tone"][index]
        case .accepted: return ["Accurate Acceptance System", "Reactive Acceptance System", "Highly Reactive Acceptance System"][index]
        case .resonant: return ["Strong Mirror Neuron Activity", "Moderate Mirror Neuron Activity", "Low Mirror Neuron Activity"][index]
        case .energetic: return ["Healthy Reward System", "Moderate Reward System", "Low Relational Reward"][index]
        }
    }

    static func tierDescription(for domain: CAREDomain, score: Double) -> String {
        let index = tier(for: score)
        switch domain {
        case .calm:
            return [
                "Your smart vagus nerve helps calm and relax you. Your relationships help you manage the stress of day-to-day life.",
                "Some relationships may trigger stress or anxiety. Past stressful relationship patterns can make it harder to feel calm and supported in your current relationships.",
                "Relationships may often feel unsafe or add to your stress. Current or past difficult relationships may keep your nervous system reactive and prepared for threat."
            ][index]
        case .accepted:
            return [
                "Your brain accurately recognizes when you are included or excluded. Most of your relationships feel safe and give you a sense of belonging.",
                "You may sometimes feel left out, disconnected, or as though you don’t belong, even when you are with others. Past relationship patterns may influence how safe and included you feel now.",
                "Your alarm system for rejection or exclusion may be frequently activated. This can make it difficult to feel a sense of belonging and may cause relationships to feel less safe or accepting than they are."
            ][index]
        case .resonant:
            return [
                "You generally feel seen and understood by others and are able to understand their feelings and intentions. Relationships tend to feel emotionally easy and connected.",
                "Reading other people can sometimes be difficult. You may occasionally feel misunderstood or misread other people’s intentions and reactions.",
                "Understanding other people’s feelings and intentions may often feel difficult or overwhelming. Misunderstandings and disconnections may occur more frequently in relationships."
            ][index]
        case .energetic:
            return [
                "Connection with others tends to feel rewarding and energizing. Healthy relationships increase your motivation and support your ability to act on behalf of yourself and your relationships.",
                "Relationships may sometimes feel rewarding but can also feel neutral or draining. You may feel energized by certain relationships more than others.",
                "Relationships may rarely feel energizing or rewarding, and being alone may sometimes feel preferable. You may be more likely to seek feelings of reward or stimulation outside of relationships."
            ][index]
        }
    }

    static func exerciseRoute(for domain: CAREDomain) -> AppRoute {
        switch domain {
        case .calm: return .calmExercises
        case .accepted: return .acceptedExercises
        case .resonant: return .resonantExercises
        case .energetic: return .energeticExercises
        }
    }
}

#Preview {
    SurveyResultsV2View(result: .figmaMockResult)
}
