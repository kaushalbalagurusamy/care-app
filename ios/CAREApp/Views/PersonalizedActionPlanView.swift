import SwiftUI

/// Free preview based on Figma frame 215:5. The purchase button uses StoreKit's
/// storefront price when available; preview access exists only in Debug builds.
struct PremiumUnlockView: View {
    @Environment(CAREPremiumAccess.self) private var premium
    @State private var showUnlockConfirmation = false
    let router: AppRouter
    let result: AssessmentResult?

    private var focus: CAREDomain? {
        guard let result else { return nil }
        return CAREDomain.allCases.min {
            (result.domainScores[$0]?.percentage ?? 1) < (result.domainScores[$1]?.percentage ?? 1)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HeaderNavBar(showBackButton: true, showHomeButton: true, showSparkleButton: false, onBack: { router.pop() })
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 7) {
                        Text("Unlock Your C.A.R.E. Exercises")
                            .font(Theme.Typography.poppins(.bold, size: 22))
                            .foregroundStyle(Theme.Colors.textPrimary)
                        Text("Turn your assessment results into a personalized path for strengthening connection.")
                            .font(Theme.Typography.poppins(.regular, size: 13))
                            .foregroundStyle(Theme.Colors.textSecondary)
                    }
                    .padding(.top, Theme.Spacing.headerTitleSpacing)

                    VStack(alignment: .leading, spacing: 17) {
                        HStack(spacing: 8) {
                            AppIcon.sparkle.view(size: 20)
                            Text("Your C.A.R.E. Plan")
                                .font(Theme.Typography.poppins(.bold, size: 17))
                                .foregroundStyle(Theme.Colors.textPrimary)
                            Spacer()
                            Text("TAILORED")
                                .font(Theme.Typography.poppins(.bold, size: 10))
                                .foregroundStyle(Theme.Colors.primary)
                                .padding(.horizontal, 11).padding(.vertical, 6)
                                .background(.white, in: Capsule())
                        }
                        HStack(spacing: 6) {
                            ForEach(CAREDomain.allCases, id: \.self) { domain in
                                VStack(spacing: 7) {
                                    Circle().fill(domain.accentColor).frame(width: 9, height: 9)
                                    Text(domain.title)
                                        .font(Theme.Typography.poppins(.medium, size: 10))
                                    Text(score(domain))
                                        .font(Theme.Typography.poppins(.bold, size: 13))
                                        .foregroundStyle(domain.accentColor)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(.white, in: RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        Text(focus.map { "Your current focus: \($0.title) Pathway" } ?? "Complete an assessment to see your pathway focus")
                            .font(Theme.Typography.poppins(.semiBold, size: 13))
                            .foregroundStyle(Theme.Colors.primary)
                    }
                    .padding(18)
                    .background(Color(hex: "#E1EFFE"), in: RoundedRectangle(cornerRadius: 20))

                    VStack(alignment: .leading, spacing: 18) {
                        benefit("Personalized plan based on your latest C.A.R.E. scores")
                        benefit("Unlock \(ExerciseItem.allExercises.count - ExerciseItem.freeExercises.count) additional exercises from Wired to Connect by Amy Banks, MD")
                        benefit("Exercise recommendations based on the pathways that need the most support")
                    }
                    .padding(.vertical, 4)

                    Button { showUnlockConfirmation = true } label: {
                        Text(premium.product.map { "Unlock Exercises + Personalization — \($0.displayPrice)" } ?? "Checking purchase availability…")
                            .font(Theme.Typography.poppins(.semiBold, size: 14))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, minHeight: 54)
                            .background(Theme.Colors.primary, in: RoundedRectangle(cornerRadius: 18))
                    }
                    .disabled(premium.isBusy || premium.product == nil)
                    .accessibilityIdentifier("UnlockCAREPurchaseButton")

                    if premium.product == nil {
                        Button("Try loading purchase again") { Task { await premium.loadProduct() } }
                            .font(Theme.Typography.poppins(.medium, size: 12))
                            .frame(maxWidth: .infinity)
                    }

#if DEBUG
                    Button("Preview Paid Screens (No Charge)") { premium.simulatePurchase() }
                        .font(Theme.Typography.poppins(.medium, size: 12))
                        .frame(maxWidth: .infinity)
#endif

                    Link(destination: URL(string: "https://www.penguinrandomhouse.com/books/316116/wired-to-connect-by-amy-banks-md-with-leigh-ann-hirschman/")!) {
                        HStack(spacing: 6) {
                            Text("Explore Wired to Connect")
                            AppIcon.arrowRight.view(size: 14, weight: .semibold, color: Theme.Colors.primary)
                        }
                        .font(Theme.Typography.poppins(.semiBold, size: 14))
                        .foregroundStyle(Theme.Colors.primary)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.Colors.primary, lineWidth: 1))
                    }

                    Button("Preview Your C.A.R.E. Action Plan") { premium.previewActionPlan() }
                        .font(Theme.Typography.poppins(.medium, size: 13))
                        .frame(maxWidth: .infinity)
                        .disabled(result == nil)
                        .accessibilityIdentifier("PreviewCAREActionPlanButton")
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .background(.white)
        .alert("Unlock all C.A.R.E. exercises?", isPresented: $showUnlockConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Continue to Apple Purchase") { Task { await premium.purchase() } }
        } message: {
#if DEBUG
            Text("Apple will ask you to confirm the one-time \(premium.product?.displayPrice ?? "") purchase. Xcode and TestFlight test purchases do not charge you.")
#else
            Text("Apple will ask you to confirm the one-time \(premium.product?.displayPrice ?? "") purchase before charging you.")
#endif
        }
        .alert("Purchase unavailable", isPresented: Binding(get: { premium.errorMessage != nil }, set: { if !$0 { premium.errorMessage = nil } })) {
            Button("OK", role: .cancel) { premium.errorMessage = nil }
        } message: { Text(premium.errorMessage ?? "") }
        .accessibilityIdentifier("CAREUnlockScreen")
    }

    private func score(_ domain: CAREDomain) -> String {
        guard let score = result?.domainScores[domain] else { return "—/125" }
        return "\(Int(score.earnedPoints.rounded()))/\(Int(score.maxPossiblePoints.rounded()))"
    }

    private func benefit(_ copy: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Theme.Colors.primary)
                .font(.system(size: 20))
            Text(copy)
                .font(Theme.Typography.poppins(.medium, size: 13))
                .foregroundStyle(Theme.Colors.textPrimary)
        }
    }
}

/// Visual review of the action plan after the assessment has been unlocked.
public struct PersonalizedActionPlanView: View {
    @Environment(CAREPremiumAccess.self) private var premium: CAREPremiumAccess?
    public let router: AppRouter
    public let result: AssessmentResult
    public let isPreview: Bool

    public init(router: AppRouter, result: AssessmentResult, isPreview: Bool = false) {
        self.router = router
        self.result = result
        self.isPreview = isPreview
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
        let pathway = ExerciseItem.allExercises.filter { $0.category == focusCategory }
        guard let prm = pathway.first(where: \.isPositiveRelationalMoment) else {
            return Array(pathway.prefix(3))
        }
        return [prm] + pathway.filter { !$0.isPositiveRelationalMoment }.prefix(2)
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
            HeaderNavBar(showBackButton: true, showHomeButton: true, showSparkleButton: false, onBack: {
                if isPreview { premium?.isPreviewingActionPlan = false }
                else { router.pop() }
            })
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

                    if isPreview {
                        Text("PREVIEW · This plan is for viewing only")
                            .font(Theme.Typography.poppins(.semiBold, size: 12))
                            .foregroundStyle(Theme.Colors.primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 9)
                            .background(Theme.Colors.primary.opacity(0.09), in: Capsule())
                            .accessibilityIdentifier("CareActionPlanReadOnlyPreview")
                    }

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

                    if isPreview {
                        Button("Unlock Exercises + Personalization") { premium?.isPreviewingActionPlan = false }
                            .font(Theme.Typography.poppins(.semiBold, size: 14))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(Theme.Colors.primary, in: RoundedRectangle(cornerRadius: 14))
                            .accessibilityIdentifier("PreviewToUnlockButton")
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 28)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background.ignoresSafeArea())
        .accessibilityIdentifier("CareActionPlanScreen")
        .onDisappear {
            if isPreview { premium?.isPreviewingActionPlan = false }
        }
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
                if !isPreview {
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
