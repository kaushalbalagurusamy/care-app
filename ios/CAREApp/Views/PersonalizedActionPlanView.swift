import SwiftUI

/// Visual review of the action plan after the assessment has been unlocked.
public struct PersonalizedActionPlanView: View {
    public let router: AppRouter
    public let result: AssessmentResult

    public init(router: AppRouter, result: AssessmentResult) {
        self.router = router
        self.result = result
    }

    private var focusDomain: CAREDomain {
        CAREDomain.allCases.min {
            (result.domainScores[$0]?.percentage ?? 1) < (result.domainScores[$1]?.percentage ?? 1)
        } ?? .calm
    }

    private var focusCategory: ExerciseCategory {
        ExerciseCategory.allCases.first { $0.rawValue == focusDomain.title } ?? .calm
    }

    private var recommendations: [ExerciseItem] {
        Array(ExerciseItem.allExercises.filter { $0.category == focusCategory }.prefix(3))
    }

    private var focusCopy: String {
        let lowest = result.domainScores[focusDomain]?.percentage ?? 1
        let tied = CAREDomain.allCases.filter { abs((result.domainScores[$0]?.percentage ?? 1) - lowest) < 0.001 }
        if tied.count > 1 {
            return "Your pathway scores are tied today. Begin with \(focusDomain.title), then explore every pathway at your own pace."
        }
        return "Start with \(focusDomain.title). This is your lowest pathway score today, so the exercises below give it extra attention. Explore every pathway at your own pace."
    }

    public var body: some View {
        VStack(spacing: 0) {
            HeaderNavBar(showBackButton: true, showHomeButton: true, showSparkleButton: false, onBack: { router.pop() })
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("YOUR PERSONALIZED PLAN")
                            .font(Theme.Typography.poppins(.bold, size: 12))
                            .tracking(1)
                            .foregroundStyle(Theme.Colors.primary)
                        Text("Your C.A.R.E. Action Plan")
                            .font(Theme.Typography.poppins(.bold, size: 27))
                            .foregroundStyle(Theme.Colors.textPrimary)
                        Text("A practical place to begin, based on your latest assessment.")
                            .font(Theme.Typography.poppins(.regular, size: 14))
                            .foregroundStyle(Theme.Colors.textSecondary)
                    }
                    .padding(.top, Theme.Spacing.headerTitleSpacing)

                    VStack(alignment: .leading, spacing: 14) {
                        Text("Your C.A.R.E. pathways")
                            .font(Theme.Typography.poppins(.semiBold, size: 17))
                            .foregroundStyle(Theme.Colors.textPrimary)
                        HStack(spacing: 7) {
                            ForEach(CAREDomain.allCases, id: \.self) { domain in
                                VStack(spacing: 4) {
                                    Text(domain.title)
                                        .font(Theme.Typography.poppins(.medium, size: 10))
                                    Text(scoreLabel(domain))
                                        .font(Theme.Typography.poppins(.bold, size: 14))
                                }
                                .frame(maxWidth: .infinity)
                                .foregroundStyle(domain == focusDomain ? Theme.Colors.primary : Theme.Colors.textPrimary)
                                .padding(.vertical, 10)
                                .background(domain == focusDomain ? Theme.Colors.primary.opacity(0.12) : Theme.Colors.surfaceSecondary, in: RoundedRectangle(cornerRadius: 10))
                            }
                        }
                        Text(focusCopy)
                            .font(Theme.Typography.poppins(.regular, size: 13))
                            .foregroundStyle(Theme.Colors.textPrimary)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(hex: "#FEF3C7").opacity(0.7), in: RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(16)
                    .background(Theme.Colors.cardSurface, in: RoundedRectangle(cornerRadius: 18))

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your first steps")
                            .font(Theme.Typography.poppins(.bold, size: 19))
                        planStep(1, "Choose one short \(focusDomain.title) exercise below.")
                        planStep(2, "Notice how you feel before and after. Repeat the ones that help.")
                        planStep(3, "Explore another pathway when you feel ready. Your plan can change with your next assessment.")
                    }
                    .foregroundStyle(Theme.Colors.textPrimary)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Recommended for you")
                            .font(Theme.Typography.poppins(.bold, size: 19))
                            .foregroundStyle(focusCategory.accentColor)
                        Text("A starting set for your \(focusDomain.title) pathway")
                            .font(Theme.Typography.poppins(.regular, size: 13))
                            .foregroundStyle(Theme.Colors.textSecondary)
                        ForEach(recommendations) { exercise in exerciseRow(exercise, showDescription: true) }
                    }
                    .padding(14)
                    .background(focusCategory.accentColor.opacity(0.07), in: RoundedRectangle(cornerRadius: 18))

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Explore every pathway")
                            .font(Theme.Typography.poppins(.bold, size: 19))
                            .foregroundStyle(Theme.Colors.textPrimary)
                        Text("\(ExerciseItem.allExercises.count) exercises across Calm, Accepted, Resonant, and Energetic")
                            .font(Theme.Typography.poppins(.regular, size: 13))
                            .foregroundStyle(Theme.Colors.textSecondary)
                        ForEach(ExerciseCategory.allCases) { category in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(category.rawValue)
                                        .font(Theme.Typography.poppins(.bold, size: 16))
                                        .foregroundStyle(category.accentColor)
                                    Spacer()
                                    Text("\(ExerciseItem.allExercises.filter { $0.category == category }.count) exercises")
                                        .font(Theme.Typography.poppins(.medium, size: 11))
                                        .foregroundStyle(Theme.Colors.textSecondary)
                                }
                                ForEach(ExerciseItem.allExercises.filter { $0.category == category }) { exercise in
                                    exerciseRow(exercise, showDescription: false)
                                }
                            }
                            .padding(14)
                            .background(category.accentColor.opacity(0.07), in: RoundedRectangle(cornerRadius: 16))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 28)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background.ignoresSafeArea())
        .accessibilityIdentifier("CareActionPlanScreen")
    }

    private func scoreLabel(_ domain: CAREDomain) -> String {
        guard let score = result.domainScores[domain] else { return "—" }
        return "\(Int((score.percentage * 100).rounded()))%"
    }

    private func planStep(_ number: Int, _ copy: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(Theme.Typography.poppins(.bold, size: 12))
                .foregroundStyle(.white)
                .frame(width: 25, height: 25)
                .background(Theme.Colors.primary, in: Circle())
            Text(copy)
                .font(Theme.Typography.poppins(.regular, size: 13))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func exerciseRow(_ item: ExerciseItem, showDescription: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 10) {
                ExerciseEmojiView(emoji: item.emoji, size: 21)
                    .frame(width: 34, height: 34)
                    .background(item.category.accentColor.opacity(0.12), in: Circle())
                VStack(alignment: .leading, spacing: 3) {
                    Text(item.title)
                        .font(Theme.Typography.poppins(.semiBold, size: 13))
                        .foregroundStyle(Theme.Colors.textPrimary)
                    if showDescription {
                        Text(item.subtitle)
                            .font(Theme.Typography.poppins(.regular, size: 12))
                            .foregroundStyle(Theme.Colors.textSecondary)
                    }
                }
                Spacer(minLength: 0)
            }
            HStack(spacing: 10) {
                Text(item.durationMinutesRange)
                    .font(Theme.Typography.poppins(.medium, size: 11))
                    .foregroundStyle(item.category.accentColor)
                    .padding(.leading, 44)
                Spacer()
                Button {
                    router.navigate(to: exerciseRoute(for: item))
                } label: {
                    HStack(spacing: 5) {
                        Text("Do Exercise")
                        Image(systemName: "arrow.right")
                    }
                    .font(Theme.Typography.poppins(.semiBold, size: 12))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 13)
                    .frame(height: 34)
                    .background(item.category.accentColor, in: RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("PlanDoExercise_\(item.id)")
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12)
            .strokeBorder(item.category.accentColor.opacity(0.55), lineWidth: 1))
    }

    private func exerciseRoute(for item: ExerciseItem) -> AppRoute {
        switch item.id {
        case "watch-something-funny": return .watchFunny
        case "keep-photo-close": return .keepPhoto
        case "belonging-list": return .belongingList
        case "share-something-small": return .shareSomethingSmall
        case "mirror-emotion": return .mirrorEmotion
        case "mirror-loved-one": return .mirrorLovedOne
        case "share-something-new": return .shareSomethingNew
        case "connection-countdown": return .connectionCountdown
        default: return .guidedExercise(item.id)
        }
    }
}

#Preview("C.A.R.E. Action Plan") {
    PersonalizedActionPlanView(router: AppRouter(), result: .figmaMockResult)
}
