import SwiftUI

// MARK: - Screen 10: Historical Past Results & Relational Trends (Figma Frame 95:2)
public struct PastResultsView: View {
    public let router: AppRouter
    @State private var expandedContactId: UUID? = nil
    
    private let samplePeople = Person.mockFigmaContacts
    
    public init(router: AppRouter) {
        self.router = router
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            HeaderNavBar(
                showBackButton: true,
                showHomeButton: true,
                showChartButton: false,
                showProfileButton: true,
                onBack: { router.pop() },
                onHome: { router.popToRoot() },
                onProfile: {}
            )
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Title Section
                    Text("Past Results")
                        .font(Theme.Typography.title)
                        .foregroundColor(Theme.Colors.textPrimary)
                        .padding(.top, 8)
                    
                    // MARK: 1. Total Scores Bubble
                    BubbleCardContainer(title: "Total Scores Trend") {
                        HStack(spacing: 20) {
                            ScoreBubbleView(score: 82, maxScore: 100, title: "Latest")
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("May 29 Assessment")
                                    .font(Theme.Typography.cardTitle)
                                    .foregroundColor(Theme.Colors.textPrimary)
                                
                                Text("+12 pts from last evaluation")
                                    .font(Theme.Typography.caption)
                                    .foregroundColor(Theme.Colors.Safety.lowRisk)
                                
                                Text("Consistently improving relational safety across core inner circle.")
                                    .font(Theme.Typography.caption)
                                    .foregroundColor(Theme.Colors.textSecondary)
                            }
                        }
                    }
                    
                    // MARK: 2. C.A.R.E. Results Donut Bubble
                    BubbleCardContainer(title: "C.A.R.E. Score Breakdown") {
                        DonutChartView(
                            segments: [
                                DonutSegment(title: "Calm", color: Theme.Colors.Domains.calm, percentage: 0.25),
                                DonutSegment(title: "Accepted", color: Theme.Colors.Domains.accepted, percentage: 0.25),
                                DonutSegment(title: "Resonant", color: Theme.Colors.Domains.resonant, percentage: 0.25),
                                DonutSegment(title: "Energetic", color: Theme.Colors.Domains.energetic, percentage: 0.25)
                            ],
                            gapDegrees: 8.0
                        )
                        .frame(maxWidth: .infinity)
                    }
                    
                    // MARK: 3. Relational Safety Donut Bubble
                    BubbleCardContainer(title: "Relational Safety Distribution") {
                        VStack(spacing: 16) {
                            DonutChartView(
                                segments: [
                                    DonutSegment(title: "Safe", color: Theme.Colors.Safety.lowRisk, percentage: 0.40),
                                    DonutSegment(title: "Medium Risk", color: Theme.Colors.Safety.moderateRisk, percentage: 0.40),
                                    DonutSegment(title: "High Risk", color: Theme.Colors.Safety.highRisk, percentage: 0.20)
                                ],
                                gapDegrees: 8.0
                            )
                            .frame(maxWidth: .infinity)
                            
                            HStack(spacing: 16) {
                                Label("40% Safe", systemImage: "circle.fill")
                                    .font(Theme.Typography.caption)
                                    .foregroundColor(Theme.Colors.Safety.lowRisk)
                                Label("40% Med", systemImage: "circle.fill")
                                    .font(Theme.Typography.caption)
                                    .foregroundColor(Theme.Colors.Safety.moderateRisk)
                                Label("20% High", systemImage: "circle.fill")
                                    .font(Theme.Typography.caption)
                                    .foregroundColor(Theme.Colors.Safety.highRisk)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    
                    // MARK: 4. Results by Individual Accordion Bubble
                    BubbleCardContainer(title: "Results by Individual") {
                        VStack(spacing: 12) {
                            ForEach(samplePeople) { person in
                                let isExpanded = (expandedContactId == person.id)
                                
                                ExpandableAccordionCard(
                                    title: person.name,
                                    scoreLabel: person.id == samplePeople[0].id ? "83/100 Safe" : "71/100 Moderate",
                                    tier: person.id == samplePeople[0].id ? .healthy : .moderate,
                                    isExpanded: isExpanded,
                                    onToggle: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                            if expandedContactId == person.id {
                                                expandedContactId = nil
                                            } else {
                                                expandedContactId = person.id
                                            }
                                        }
                                    }
                                )
                            }
                        }
                    }
                    
                    // Return Action Button
                    SecondaryButton(title: "Return to Home", icon: "house.fill") {
                        router.popToRoot()
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
        .background(Theme.Colors.background)
        .onAppear {
            if expandedContactId == nil, let first = samplePeople.first {
                expandedContactId = first.id
            }
        }
    }
}

// MARK: - Previews
#Preview("Past Results View") {
    PastResultsView(router: AppRouter())
}
