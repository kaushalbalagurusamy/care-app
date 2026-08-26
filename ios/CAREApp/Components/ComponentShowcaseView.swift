import SwiftUI

// MARK: - SOTA Design System Showcase & Storybook (Debug Gallery)
public struct ComponentShowcaseView: View {
    @State private var slider1: Double = 0.30
    @State private var slider2: Double = 0.25
    @State private var isPillSelected1: Bool = true
    @State private var isPillSelected2: Bool = false
    @State private var isAccordionExpanded: Bool = true
    @State private var activeCardIndex: Int = 0
    @State private var buttonLoading: Bool = false
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    
                    // MARK: 1. Header Nav Bars
                    ShowcaseSection(title: "1. Header Navigation Bars") {
                        VStack(spacing: 16) {
                            HeaderNavBar(mode: .home(userName: "Sarah Mitchell", streakCount: 5))
                            HeaderNavBar(mode: .detail(title: "C.A.R.E. Overview", progress: 0.60, onBack: {}))
                            HeaderNavBar(mode: .modal(title: "About Risk Groups", onClose: {}))
                        }
                    }
                    
                    // MARK: 2. Buttons & Actions
                    ShowcaseSection(title: "2. Interactive Action Buttons") {
                        VStack(spacing: 12) {
                            PrimaryButton(title: "Begin the Survey", icon: "arrow.right", action: {})
                            PrimaryButton(title: "Next: James Cooper", action: {})
                            PrimaryButton(title: "Loading State", isLoading: buttonLoading, action: {
                                buttonLoading.toggle()
                            })
                            PrimaryButton(title: "Disabled Button", isEnabled: false, action: {})
                            SecondaryButton(title: "Return to Home", icon: "house.fill", action: {})
                        }
                    }
                    
                    // MARK: 3. Donut Charts & Score Bubbles
                    ShowcaseSection(title: "3. Donut Chart & Score Bubbles") {
                        VStack(spacing: 24) {
                            // Donut Chart
                            VStack(spacing: 16) {
                                DonutChartView(segments: [
                                    DonutSegment(title: "Safe", color: Theme.Colors.Safety.lowRisk, percentage: 0.21),
                                    DonutSegment(title: "Medium Risk", color: Theme.Colors.Safety.moderateRisk, percentage: 0.39),
                                    DonutSegment(title: "High Risk", color: Theme.Colors.Safety.highRisk, percentage: 0.40)
                                ])
                                
                                HStack(spacing: 12) {
                                    Label("21% Safe", systemImage: "circle.fill")
                                        .font(Theme.Typography.caption)
                                        .foregroundColor(Theme.Colors.Safety.lowRisk)
                                    Label("39% Med", systemImage: "circle.fill")
                                        .font(Theme.Typography.caption)
                                        .foregroundColor(Theme.Colors.Safety.moderateRisk)
                                    Label("40% High", systemImage: "circle.fill")
                                        .font(Theme.Typography.caption)
                                        .foregroundColor(Theme.Colors.Safety.highRisk)
                                }
                            }
                            .padding(20)
                            .background(Theme.Colors.cardSurface)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            
                            // Score Bubbles
                            HStack(spacing: 16) {
                                ScoreBubbleView(score: 80, maxScore: 100, title: "Overall")
                                ScoreBubbleView(score: 65, maxScore: 100, title: "Moderate")
                                ScoreBubbleView(score: 45, maxScore: 100, title: "High Risk")
                            }
                        }
                    }
                    
                    // MARK: 4. Contact Cards & Selection Pills
                    ShowcaseSection(title: "4. Contact Cards & Selection Pills") {
                        VStack(spacing: 12) {
                            RelationshipSelectionPill(
                                initials: "SM",
                                name: "Sarah Mitchell",
                                subtitle: "Partner, 32",
                                isSelected: isPillSelected1,
                                onToggle: { isPillSelected1.toggle() }
                            )
                            
                            RelationshipSelectionPill(
                                initials: "JC",
                                name: "James Cooper",
                                subtitle: "Friend, 28",
                                isSelected: isPillSelected2,
                                onToggle: { isPillSelected2.toggle() }
                            )
                        }
                    }
                    
                    // MARK: 5. Results by Individual & Pagination
                    ShowcaseSection(title: "5. Individual Result Card & Carousel Dots") {
                        let sampleResult = IndividualResult(
                            participant: AssessmentParticipant(
                                person: Person(name: "Sarah Mitchell", initials: "SM", category: .partner, age: 32),
                                percentTimeSpent: 0.30
                            ),
                            normalizedScore: 80.0,
                            safetyTier: .healthy,
                            domainBreakdown: [.calm: 18, .accepted: 20, .resonant: 15, .energetic: 22]
                        )
                        
                        VStack(spacing: 16) {
                            IndividualResultCard(result: sampleResult)
                            
                            PageIndicatorDots(totalCount: 5, currentIndex: activeCardIndex)
                            
                            // Interactive Page Stepper
                            HStack {
                                Button("Prev Dot") {
                                    if activeCardIndex > 0 { activeCardIndex -= 1 }
                                }
                                .font(Theme.Typography.caption)
                                
                                Spacer()
                                
                                Button("Next Dot") {
                                    if activeCardIndex < 4 { activeCardIndex += 1 }
                                }
                                .font(Theme.Typography.caption)
                            }
                            .padding(.horizontal, 40)
                        }
                    }
                    
                    // MARK: 6. Frequency Sliders
                    ShowcaseSection(title: "6. Interactive Frequency Partition Sliders") {
                        VStack(spacing: 12) {
                            FrequencySliderRow(initials: "SM", name: "Sarah Mitchell", percentage: $slider1)
                            FrequencySliderRow(initials: "JC", name: "James Cooper", percentage: $slider2)
                        }
                    }
                    
                    // MARK: 7. Dashboard Widgets
                    ShowcaseSection(title: "7. Dashboard Metric & Action Cards") {
                        VStack(spacing: 16) {
                            StreakBadgeView(daysCount: 5)
                            ActionCardView(number: "01", title: "Education", subtitle: "Learn Wellness", backgroundImageName: "card_education_bg", action: {})
                            ActionCardView(number: "02", title: "Assessment", subtitle: "Track Mind", backgroundImageName: "card_assessment_bg", action: {})
                            ActionCardView(number: "03", title: "Exercises", subtitle: "Active Care", backgroundImageName: "card_exercises_bg", action: {})
                        }
                    }
                    
                    // MARK: 8. Historical Accordion Cards
                    ShowcaseSection(title: "8. Expandable Historical Accordions") {
                        ExpandableAccordionCard(
                            title: "Sarah Mitchell",
                            scoreLabel: "83/100 Safe",
                            tier: .healthy,
                            isExpanded: isAccordionExpanded,
                            onToggle: { isAccordionExpanded.toggle() }
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .background(Theme.Colors.surfaceSecondary)
            .navigationTitle("CARE Design System")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Internal Section Container
struct ShowcaseSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(Theme.Typography.headline)
                .foregroundColor(Theme.Colors.textPrimary)
            
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Previews
#Preview("Complete Design System Showcase") {
    ComponentShowcaseView()
}
