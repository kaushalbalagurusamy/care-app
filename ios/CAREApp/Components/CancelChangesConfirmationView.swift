import SwiftUI

// MARK: - Cancel Changes Confirmation Modal (Figma Frame 415:1014)
public struct CancelChangesConfirmationView: View {
    public let onKeepEditing: () -> Void
    public let onCancelWithoutSaving: () -> Void
    
    public init(
        onKeepEditing: @escaping () -> Void,
        onCancelWithoutSaving: @escaping () -> Void
    ) {
        self.onKeepEditing = onKeepEditing
        self.onCancelWithoutSaving = onCancelWithoutSaving
    }
    
    public var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    onKeepEditing()
                }
            
            VStack(spacing: 20) {
                VStack(spacing: 10) {
                    Text("Cancel changes?")
                        .font(Theme.Typography.poppins(.bold, size: 20))
                        .foregroundColor(Theme.Colors.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    Text("Are you sure you want to cancel? Any information you’ve entered on this page will not be saved.")
                        .font(Theme.Typography.poppins(.regular, size: 14))
                        .foregroundColor(Theme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                }
                .padding(.horizontal, 8)
                
                VStack(spacing: 12) {
                    PrimaryButton(
                        title: "Keep Editing",
                        action: onKeepEditing
                    )
                    
                    Button(action: {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        onCancelWithoutSaving()
                    }) {
                        Text("Cancel Without Saving")
                            .font(Theme.Typography.poppins(.semiBold, size: 16))
                            .foregroundColor(Theme.Colors.primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                    }
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.12), radius: 24, x: 0, y: 12)
            )
            .padding(.horizontal, 28)
        }
    }
}

#Preview {
    CancelChangesConfirmationView(onKeepEditing: {}, onCancelWithoutSaving: {})
}
