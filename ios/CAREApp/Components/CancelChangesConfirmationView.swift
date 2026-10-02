import SwiftUI

// MARK: - Cancel Changes Confirmation Modal (Figma Frame 415:1014)
public struct CancelChangesConfirmationView: View {
    public let onKeepEditing: () -> Void
    public let onCancelWithoutSaving: () -> Void
    public let title: String
    public let message: String
    public let primaryTitle: String
    public let secondaryTitle: String
    
    public init(
        onKeepEditing: @escaping () -> Void,
        onCancelWithoutSaving: @escaping () -> Void,
        title: String = "Cancel changes?",
        message: String = "Are you sure you want to cancel? Any information you’ve entered on this page will not be saved.",
        primaryTitle: String = "Keep Editing",
        secondaryTitle: String = "Cancel Without Saving"
    ) {
        self.onKeepEditing = onKeepEditing
        self.onCancelWithoutSaving = onCancelWithoutSaving
        self.title = title
        self.message = message
        self.primaryTitle = primaryTitle
        self.secondaryTitle = secondaryTitle
    }
    
    public var body: some View {
        ZStack {
            Color.black.opacity(0.18)
                .ignoresSafeArea()
                .onTapGesture {
                    onKeepEditing()
                }
            
            VStack(alignment: .leading, spacing: 28) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(title)
                        .font(Theme.Typography.poppins(.bold, size: 20))
                        .foregroundColor(Theme.Colors.textPrimary)
                    
                    Text(message)
                        .font(Theme.Typography.poppins(.regular, size: 14))
                        .foregroundColor(Theme.Colors.textSecondary)
                        .lineSpacing(2)
                }
                
                VStack(spacing: 8) {
                    PrimaryButton(
                        title: primaryTitle,
                        action: onKeepEditing
                    )
                    
                    Button(action: {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        onCancelWithoutSaving()
                    }) {
                        Text(secondaryTitle)
                            .font(Theme.Typography.poppins(.semiBold, size: 16))
                            .foregroundColor(Theme.Colors.primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                    }
                }
            }
            .padding(22)
            .frame(maxWidth: 350)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color(hex: "#FAFAFA"))
                    .shadow(color: Color.black.opacity(0.12), radius: 24, x: 0, y: 12)
            )
            .padding(.horizontal, 20)
        }
    }
}

public struct ExerciseLeaveConfirmationView: View {
    @Environment(AppRouter.self) private var router: AppRouter?
    @Environment(AppEnvironment.self) private var environment: AppEnvironment?
    public let onKeepEditing: () -> Void
    public let onLeave: () -> Void

    private var saveFailed: Bool {
        let id: String? = switch router?.currentRoute {
        case .watchFunny: "watch-something-funny"
        case .keepPhoto: "keep-photo-close"
        case .belongingList: "belonging-list"
        case .shareSomethingSmall: "share-something-small"
        case .mirrorEmotion: "mirror-emotion"
        case .mirrorLovedOne: "mirror-loved-one"
        case .shareSomethingNew: "share-something-new"
        case .connectionCountdown: "connection-countdown"
        case .guidedExercise(let id): id
        default: nil
        }
        return id.map { environment?.draftStore.failedExerciseSaves.contains($0) == true } ?? false
    }

    public var body: some View {
        CancelChangesConfirmationView(
            onKeepEditing: onKeepEditing,
            onCancelWithoutSaving: onLeave,
            title: "Leave this exercise?",
            message: saveFailed
                ? "Your latest changes could not be saved. Keep editing and retry, or leave without those changes."
                : "Your progress is saved on this device. You can come back and continue where you left off.",
            primaryTitle: "Keep Editing",
            secondaryTitle: saveFailed ? "Leave Without Changes" : "Leave Exercise"
        )
    }
}

#Preview {
    CancelChangesConfirmationView(onKeepEditing: {}, onCancelWithoutSaving: {})
}
