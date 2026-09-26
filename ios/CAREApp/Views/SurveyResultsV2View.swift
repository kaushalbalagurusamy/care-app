import SwiftUI

// MARK: - Screen: Survey Results V2 (Figma Frame 292:4 & Node 239:8)
public struct SurveyResultsV2View: View {
    @Environment(AppRouter.self) private var router: AppRouter?
    
    @State private var searchText: String = ""
    @State private var expandedCategories: Set<String> = ["Calm"]
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            HeaderNavBar(
                showBackButton: true,
                showHomeButton: true,
                showSparkleButton: true,
                showChartButton: true,
                showProfileButton: true,
                onBack: { router?.pop() }
            )
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Title Section
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Survey Results")
                            .font(Theme.Typography.poppins(.bold, size: 28))
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        Text("Review insights and relational health metrics from your latest C.A.R.E. assessment.")
                            .font(Theme.Typography.poppins(.regular, size: 14))
                            .foregroundColor(Theme.Colors.textSecondary)
                            .lineSpacing(2)
                    }
                    .padding(.top, 4)
                    
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
                                segments: [
                                    DonutSegment(title: "Calm", color: Color(hex: "#3B82F6"), percentage: 95.0 / 361.0),
                                    DonutSegment(title: "Accepted", color: Color(hex: "#10B981"), percentage: 82.0 / 361.0),
                                    DonutSegment(title: "Resonant", color: Color(hex: "#8B5CF6"), percentage: 108.0 / 361.0),
                                    DonutSegment(title: "Energetic", color: Color(hex: "#F97316"), percentage: 76.0 / 361.0)
                                ],
                                diameter: 140,
                                strokeWidth: 16
                            )
                            .frame(width: 140, height: 140)
                            
                            VStack(spacing: 1) {
                                Text("361")
                                    .font(Theme.Typography.poppins(.bold, size: 28))
                                    .foregroundColor(Theme.Colors.textPrimary)
                                Text("out of 500")
                                    .font(Theme.Typography.poppins(.regular, size: 11))
                                    .foregroundColor(Theme.Colors.textSecondary)
                            }
                        }
                        .padding(.vertical, 8)
                        
                        // 4 Category Mini-Scores
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            scoreGridItem(label: "Calm", score: "95/125", color: Color(hex: "#3B82F6"))
                            scoreGridItem(label: "Accepted", score: "82/125", color: Color(hex: "#10B981"))
                            scoreGridItem(label: "Resonant", score: "108/125", color: Color(hex: "#8B5CF6"))
                            scoreGridItem(label: "Energetic", score: "76/125", color: Color(hex: "#F97316"))
                        }
                    }
                    .padding(18)
                    .background(Color.white)
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
                        
                        categoryAccordion(
                            category: "Calm",
                            status: "Strong sense of calm and regulation",
                            score: "95 / 125",
                            explanation: "Calmness is related to the functioning of the smart vagus nerve and your social engagement system.",
                            resultTag: "YOUR RESULT · Good Vagal Tone",
                            resultDetail: "Your smart vagus nerve helps calm and relax you. Your relationships help you manage the stress of day-to-day life.",
                            exerciseButtonTitle: "Explore Calm Exercises",
                            color: Color(hex: "#3B82F6"),
                            exerciseRoute: .calmExercises
                        )
                        
                        categoryAccordion(
                            category: "Accepted",
                            status: "Sometimes sensitive to exclusion",
                            score: "82 / 125",
                            explanation: "Acceptance reflects how safe and included you feel in your relationships. It measures your sense of belonging and how secure you feel with those around you.",
                            resultTag: "YOUR RESULT · Reactive Acceptance System",
                            resultDetail: "You may sometimes feel left out, disconnected, or as though you don't belong, even when you are with others. Past relationship patterns may influence how safe and included you feel now.",
                            exerciseButtonTitle: "Explore Accepted Exercises",
                            color: Color(hex: "#10B981"),
                            exerciseRoute: .belongingList
                        )
                        
                        categoryAccordion(
                            category: "Resonant",
                            status: "Understanding comes easily",
                            score: "108 / 125",
                            explanation: "Resonance captures the depth of mutual understanding in your relationships. It reflects how well you and others truly \"get\" each other on an emotional level.",
                            resultTag: "YOUR RESULT · Strong Mirror Neuron Activity",
                            resultDetail: "You generally feel seen and understood by others and are able to understand their feelings and intentions. Relationships tend to feel emotionally easy and connected.",
                            exerciseButtonTitle: "Explore Resonant Exercises",
                            color: Color(hex: "#8B5CF6"),
                            exerciseRoute: .careResultsExercises
                        )
                        
                        categoryAccordion(
                            category: "Energetic",
                            status: "Connection is sometimes energizing",
                            score: "76 / 125",
                            explanation: "Energy measures how much vitality and motivation you draw from your relationships. It reflects whether your connections leave you feeling energized or drained.",
                            resultTag: "YOUR RESULT · Moderate Reward System",
                            resultDetail: "Relationships may sometimes feel rewarding but can also feel neutral or draining. You may feel energized by certain relationships more than others.",
                            exerciseButtonTitle: "Explore Energetic Exercises",
                            color: Color(hex: "#F97316"),
                            exerciseRoute: .calmExercises
                        )
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
                            
                            HStack(spacing: 8) {
                                safetyPill(label: "21% Safe", color: Color(hex: "#10B981"), bg: Color(hex: "#D1FAE5"))
                                safetyPill(label: "39% Moderate Risk", color: Color(hex: "#F59E0B"), bg: Color(hex: "#FEF3C7"))
                                safetyPill(label: "40% High Risk", color: Color(hex: "#EF4444"), bg: Color(hex: "#FEE2E2"))
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
                            Text("Relationship Breakdown")
                                .font(Theme.Typography.poppins(.semiBold, size: 15))
                                .foregroundColor(Theme.Colors.textPrimary)
                            
                            HStack(spacing: 8) {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(Theme.Colors.textSecondary)
                                TextField("Search relationships...", text: $searchText)
                                    .font(Theme.Typography.poppins(.regular, size: 13.5))
                            }
                            .padding(.horizontal, 12)
                            .frame(height: 40)
                            .background(Color(hex: "#F1F5F9"))
                            .cornerRadius(10)
                            
                            VStack(spacing: 8) {
                                personRow(initials: "SM", name: "Sarah Mitchell", score: "80/100", status: "Safe", statusColor: Color(hex: "#10B981"))
                                personRow(initials: "KM", name: "Kathleen Miller", score: "62/100", status: "Moderate Risk", statusColor: Color(hex: "#F59E0B"))
                                personRow(initials: "JB", name: "James Brown", score: "41/100", status: "High Risk", statusColor: Color(hex: "#EF4444"))
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
        .background(Theme.Colors.background.ignoresSafeArea())
    }
    
    @ViewBuilder
    private func scoreGridItem(label: String, score: String, color: Color) -> some View {
        HStack {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(label)
                .font(Theme.Typography.poppins(.medium, size: 13))
                .foregroundColor(Theme.Colors.textPrimary)
            Spacer()
            Text(score)
                .font(Theme.Typography.poppins(.semiBold, size: 13))
                .foregroundColor(Theme.Colors.textSecondary)
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
                            Circle().fill(color).frame(width: 8, height: 8)
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
                            .foregroundColor(color)
                        
                        Text(resultDetail)
                            .font(Theme.Typography.poppins(.regular, size: 12.5))
                            .foregroundColor(Theme.Colors.textSecondary)
                            .lineSpacing(2)
                    }
                    .padding(12)
                    .background(color.opacity(0.08))
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
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "#E2E8F0"), lineWidth: 1)
        )
    }
    
    @ViewBuilder
    private func safetyPill(label: String, color: Color, bg: Color) -> some View {
        Text(label)
            .font(Theme.Typography.poppins(.semiBold, size: 11.5))
            .foregroundColor(color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 7)
            .background(bg)
            .clipShape(Capsule())
    }
    
    @ViewBuilder
    private func personRow(initials: String, name: String, score: String, status: String, statusColor: Color) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(Color(hex: "#EFF6FF")).frame(width: 36, height: 36)
                Text(initials)
                    .font(Theme.Typography.poppins(.bold, size: 13))
                    .foregroundColor(Theme.Colors.primary)
            }
            
            Text(name)
                .font(Theme.Typography.poppins(.medium, size: 14))
                .foregroundColor(Theme.Colors.textPrimary)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 1) {
                Text(score)
                    .font(Theme.Typography.poppins(.semiBold, size: 13))
                    .foregroundColor(Theme.Colors.textPrimary)
                Text(status)
                    .font(Theme.Typography.poppins(.regular, size: 11))
                    .foregroundColor(statusColor)
            }
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    SurveyResultsV2View()
}
