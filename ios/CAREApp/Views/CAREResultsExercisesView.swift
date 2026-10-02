import SwiftUI

// MARK: - Screen: CARE Results Exercises / Action Plan (Figma Frame 288:4 & Node 239:8)
public struct CAREResultsExercisesView: View {
    @Environment(ExerciseProgressStore.self) private var exerciseProgress: ExerciseProgressStore?
    @Environment(AppRouter.self) private var router: AppRouter?
    public let result: AssessmentResult
    
    public init(result: AssessmentResult) { self.result = result }

    private var rankedDomains: [CAREDomain] {
        CAREDomain.allCases.sorted { (result.domainScores[$0]?.percentage ?? 0) > (result.domainScores[$1]?.percentage ?? 0) }
    }

    private var focusDomain: CAREDomain { rankedDomains.last ?? .calm }

    private var recommendedExercises: [ExerciseItem] {
        ExerciseItem.allExercises.filter { $0.category.rawValue == focusDomain.title }
    }

    private func score(for domain: CAREDomain) -> String {
        guard let breakdown = result.domainScores[domain] else { return "—/125" }
        return "\(Int(breakdown.earnedPoints.rounded()))/\(Int(breakdown.maxPossiblePoints.rounded()))"
    }
    
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
                        Text("Personalized Insights")
                            .font(Theme.Typography.poppins(.semiBold, size: 13))
                            .foregroundColor(Theme.Colors.primary)
                        
                        Text("Your C.A.R.E. Profile")
                            .font(Theme.Typography.poppins(.bold, size: 28))
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        Text("Based on your latest assessment, let's explore your pathways and next steps.")
                            .font(Theme.Typography.poppins(.regular, size: 14))
                            .foregroundColor(Theme.Colors.textSecondary)
                            .lineSpacing(2)
                    }
                    .padding(.top, Theme.Spacing.headerTitleSpacing)
                    
                    // Tailored Plan Card
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Text("Your Latest C.A.R.E. Plan")
                                .font(Theme.Typography.poppins(.bold, size: 16))
                                .foregroundColor(Theme.Colors.textPrimary)
                            
                            Spacer()
                            
                            Text("TAILORED")
                                .font(Theme.Typography.poppins(.bold, size: 10))
                                .foregroundColor(Color(hex: "#166534"))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color(hex: "#DCFCE7"))
                                .clipShape(Capsule())
                        }
                        
                        // 4 Pathway Indicator Bars
                        HStack(spacing: 8) {
                            ForEach(CAREDomain.allCases, id: \.self) { domain in
                                pathwayMiniPill(label: domain.title, score: score(for: domain), color: ResultsV2Palette.donutColor(for: domain))
                            }
                        }
                        
                        // Focus Highlight Box
                        HStack(alignment: .top, spacing: 10) {
                            ExerciseEmojiView(emoji: "💡", size: 16)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Focus Highlight:")
                                    .font(Theme.Typography.poppins(.semiBold, size: 13))
                                    .foregroundColor(Color(hex: "#92400E"))
                                Text("Your latest assessment suggests focusing on your \(focusDomain.title) pathway.")
                                    .font(Theme.Typography.poppins(.regular, size: 12.5))
                                    .foregroundColor(Color(hex: "#B45309"))
                                    .lineSpacing(2)
                            }
                        }
                        .padding(12)
                        .background(Color(hex: "#FEF3C7"))
                        .cornerRadius(12)
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color(hex: "#E2E8F0"), lineWidth: 1)
                    )
                    
                    // Strengths Card
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Relational Strengths")
                            .font(Theme.Typography.poppins(.bold, size: 16))
                            .foregroundColor(Theme.Colors.textPrimary)
                        Text("Your strongest pathways are \(rankedDomains.prefix(2).map(\.title).joined(separator: " and ")). These scores reflect the relationships you assessed today.")
                            .font(Theme.Typography.poppins(.regular, size: 13.5))
                            .foregroundColor(Theme.Colors.textSecondary)
                            .lineSpacing(2)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color(hex: "#E2E8F0"), lineWidth: 1)
                    )
                    
                    // Areas to Nurture Card
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Areas to Nurture")
                            .font(Theme.Typography.poppins(.bold, size: 16))
                            .foregroundColor(Theme.Colors.textPrimary)
                        Text("Your \(focusDomain.title) score is your current area to nurture. Try a short exercise in this pathway and return to it as your relationships change.")
                            .font(Theme.Typography.poppins(.regular, size: 13.5))
                            .foregroundColor(Theme.Colors.textSecondary)
                            .lineSpacing(2)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color(hex: "#E2E8F0"), lineWidth: 1)
                    )
                    
                    // Recommended Exercises
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Recommended for You")
                                .font(Theme.Typography.poppins(.bold, size: 16))
                                .foregroundColor(Theme.Colors.textPrimary)
                            Text("Exercises for your \(focusDomain.title) pathway")
                                .font(Theme.Typography.poppins(.regular, size: 12.5))
                                .foregroundColor(Theme.Colors.textSecondary)
                        }
                        
                        ForEach(recommendedExercises) { item in
                            recommendedExerciseCard(item)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            
            // Pinned Bottom Actions
            VStack(spacing: 6) {
                PrimaryButton(
                    title: "View All Exercises",
                    action: {
                        router?.navigate(to: .exercises)
                    }
                )
                
                Text("Your plan updates as you grow. Retake assessment anytime.")
                    .font(Theme.Typography.poppins(.regular, size: 11))
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.white.ignoresSafeArea(edges: .bottom))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background.ignoresSafeArea())
    }
    
    @ViewBuilder
    private func pathwayMiniPill(label: String, score: String, color: Color) -> some View {
        VStack(spacing: 3) {
            Text(label)
                .font(Theme.Typography.poppins(.medium, size: 11))
                .foregroundColor(Theme.Colors.textSecondary)
            Text(score)
                .font(Theme.Typography.poppins(.bold, size: 12))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(hex: "#F8FAFC"))
        .cornerRadius(10)
    }
    
    @ViewBuilder
    private func recommendedExerciseCard(_ item: ExerciseItem) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 8) {
                    ExerciseEmojiView(emoji: item.emoji, size: 20)
                        .frame(width: 32, height: 32)
                        .background(item.category.accentColor.opacity(0.08), in: Circle())
                    Text(item.title)
                        .font(Theme.Typography.poppins(.semiBold, size: 15))
                        .foregroundColor(Theme.Colors.textPrimary)
                }
                Spacer()
                Image(systemName: "heart")
                    .font(.system(size: 16))
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            
            Text(item.subtitle)
                .font(Theme.Typography.poppins(.regular, size: 13))
                .foregroundColor(Theme.Colors.textSecondary)
                .lineSpacing(2)
            
            HStack {
                Text("\(item.durationMinutesRange) • \(exerciseProgress?.record(for: item.id).completionDates.count ?? 0) times completed")
                    .font(Theme.Typography.poppins(.regular, size: 11.5))
                    .foregroundColor(Theme.Colors.textSecondary)
                
                Spacer()
                
                Button(action: {
                    switch item.id {
                    case "watch-something-funny": router?.navigate(to: .watchFunny)
                    case "keep-photo-close": router?.navigate(to: .keepPhoto)
                    case "belonging-list": router?.navigate(to: .belongingList)
                    case "share-something-small": router?.navigate(to: .shareSomethingSmall)
                    case "mirror-emotion": router?.navigate(to: .mirrorEmotion)
                    case "mirror-loved-one": router?.navigate(to: .mirrorLovedOne)
                    case "share-something-new": router?.navigate(to: .shareSomethingNew)
                    case "connection-countdown": router?.navigate(to: .connectionCountdown)
                    default: router?.navigate(to: .guidedExercise(item.id))
                    }
                }) {
                    Text("Start Exercise")
                        .font(Theme.Typography.poppins(.semiBold, size: 12.5))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(Theme.Colors.primary)
                        .clipShape(Capsule())
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

#Preview {
    CAREResultsExercisesView(result: .figmaMockResult)
}
