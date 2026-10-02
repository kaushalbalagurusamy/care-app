import SwiftUI

// Figma frame 290:4, populated from the exercise just completed.
public struct ExerciseCompleteView: View {
    @Environment(AppRouter.self) private var router: AppRouter?
    @Environment(ExerciseProgressStore.self) private var progress: ExerciseProgressStore?
    public let exerciseID: String
    @State private var selectedRating = 0
    @State private var recommendedID: String?

    public init(exerciseID: String = "watch-something-funny") { self.exerciseID = exerciseID }

    private var exercise: ExerciseItem {
        ExerciseItem.allExercises.first(where: { $0.id == exerciseID }) ?? ExerciseItem.sampleCalmExercises[0]
    }
    private var record: ExerciseProgressRecord { progress?.record(for: exerciseID) ?? .init() }
    private var recommendation: ExerciseItem? {
        ExerciseItem.allExercises.first { $0.id == recommendedID }
    }
    private var accent: Color { exercise.category.accentColor }

    public var body: some View {
        VStack(spacing: 0) {
            HeaderNavBar(accentColor: accent, onBack: { router?.pop() })
            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(accent)
                        .frame(width: 80, height: 80)
                        .background(accent.opacity(0.1), in: Circle())
                        .overlay(Circle().stroke(accent.opacity(0.5), lineWidth: 1))
                        .padding(.top, Theme.Spacing.headerTitleSpacing)
                    Text("Exercise Complete!")
                        .font(Theme.Typography.poppins(.bold, size: 22))
                        .foregroundColor(Theme.Colors.textPrimary)
                    Text(exercise.title)
                        .font(Theme.Typography.poppins(.semiBold, size: 15))
                        .foregroundColor(accent)

                    HStack(spacing: 0) {
                        stat("\(record.completionDates.count)", "Completed")
                        Rectangle().fill(Color(hex: "#DCE4EE")).frame(width: 1, height: 35)
                        stat(streakLabel, "Streak", showsFire: true)
                        Rectangle().fill(Color(hex: "#DCE4EE")).frame(width: 1, height: 35)
                        stat(record.completionDates.last?.formatted(.dateTime.month(.abbreviated).day()) ?? "Today", "Last Done")
                    }
                    .padding(.vertical, 14)
                    .background(accent.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    VStack(spacing: 12) {
                        Text("How helpful was this exercise?")
                            .font(Theme.Typography.poppins(.medium, size: 13))
                        HStack(spacing: 9) {
                            ForEach(1...5, id: \.self) { star in
                                Button {
                                    selectedRating = star
                                    progress?.setRating(star, for: exerciseID)
                                } label: {
                                    Image(systemName: star <= selectedRating ? "star.fill" : "star")
                                        .font(.system(size: 24))
                                        .foregroundColor(Color(hex: "#F2A900"))
                                }
                                .accessibilityLabel("Rate \(star) stars")
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(18)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "#DCE4EE")))

                    if let recommendation {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("TRY NEXT")
                                .font(Theme.Typography.poppins(.semiBold, size: 10))
                                .foregroundColor(Theme.Colors.textSecondary)
                            HStack(spacing: 9) {
                                ExerciseEmojiView(emoji: recommendation.emoji, size: 20)
                                    .frame(width: 32, height: 32)
                                    .background(recommendation.category.accentColor.opacity(0.08), in: Circle())
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(recommendation.title)
                                        .font(Theme.Typography.poppins(.bold, size: 13))
                                    Text(recommendation.subtitle)
                                        .font(Theme.Typography.poppins(.regular, size: 11))
                                        .foregroundColor(Theme.Colors.textSecondary)
                                        .lineLimit(1)
                                }
                                Spacer()
                                Button { open(recommendation) } label: {
                                    Label("Try", systemImage: "arrow.right")
                                        .font(Theme.Typography.poppins(.semiBold, size: 11))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 10)
                                        .frame(height: 30)
                                        .background(accent)
                                        .clipShape(RoundedRectangle(cornerRadius: 9))
                                }
                            }
                            .padding(12)
                            .background(accent.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            VStack(spacing: 8) {
                Button {
                    router?.popToRoot()
                    router?.navigate(to: .exercises)
                } label: {
                    Text("View All Exercises")
                        .font(Theme.Typography.poppins(.semiBold, size: 15))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(accent)
                        .clipShape(RoundedRectangle(cornerRadius: 13))
                }
                Button { router?.popToRoot() } label: {
                    Label("Return to Home", systemImage: "arrow.left")
                        .font(Theme.Typography.poppins(.semiBold, size: 15))
                        .foregroundColor(accent)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .overlay(RoundedRectangle(cornerRadius: 13).stroke(accent))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 9)
            .background(.white)
        }
        .background(.white)
        .onAppear {
            selectedRating = record.rating
            if recommendedID == nil {
                if exerciseID == "watch-something-funny" {
                    recommendedID = "keep-photo-close"
                } else if exerciseID == "keep-photo-close" {
                    recommendedID = "watch-something-funny"
                } else {
                    recommendedID = ExerciseItem.allExercises
                    .filter { $0.category == exercise.category && $0.id != exerciseID }
                    .randomElement()?.id
                }
            }
        }
    }

    private func stat(_ value: String, _ caption: String, showsFire: Bool = false) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(Theme.Typography.poppins(.bold, size: 17))
                .foregroundColor(accent)
            HStack(spacing: 3) {
                Text(caption)
                    .font(Theme.Typography.poppins(.regular, size: 10))
                    .foregroundColor(Theme.Colors.textSecondary)
                if showsFire { ExerciseEmojiView(emoji: "🔥", size: 12) }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var streakLabel: String {
        let days = progress?.currentStreak(for: exercise.category) ?? 0
        return "\(days) \(days == 1 ? "day" : "days")"
    }

    private func open(_ item: ExerciseItem) {
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
    }
}

#Preview { ExerciseCompleteView() }
