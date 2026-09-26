import SwiftUI

// MARK: - Save Assessment Confirmation Modal (Figma Frame 419:489)
public struct SaveAssessmentConfirmationView: View {
    public let onSaveAssessment: () -> Void
    public let onDiscardAssessment: () -> Void
    
    public init(
        onSaveAssessment: @escaping () -> Void,
        onDiscardAssessment: @escaping () -> Void
    ) {
        self.onSaveAssessment = onSaveAssessment
        self.onDiscardAssessment = onDiscardAssessment
    }
    
    public var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                VStack(spacing: 10) {
                    Text("Save your assessment?")
                        .font(Theme.Typography.poppins(.bold, size: 20))
                        .foregroundColor(Theme.Colors.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    Text("Would you like to save your progress before leaving? You can resume or discard this assessment the next time you open the app or return to the Home screen.")
                        .font(Theme.Typography.poppins(.regular, size: 14))
                        .foregroundColor(Theme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                }
                .padding(.horizontal, 8)
                
                VStack(spacing: 12) {
                    PrimaryButton(
                        title: "Save Assessment",
                        action: onSaveAssessment
                    )
                    
                    Button(action: {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        onDiscardAssessment()
                    }) {
                        Text("Discard Assessment")
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
    SaveAssessmentConfirmationView(onSaveAssessment: {}, onDiscardAssessment: {})
}
