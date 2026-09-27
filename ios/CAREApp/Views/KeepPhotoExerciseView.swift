import SwiftUI

// MARK: - Screen: Keep a Photo Close Exercise (Figma Frame 275:1237 & Node 239:8)
public struct KeepPhotoExerciseView: View {
    @Environment(AppRouter.self) private var router: AppRouter?
    @State private var hasUploadedPhoto: Bool = false
    
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
                    
                    // Emoji & Badges
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            Text("📷")
                                .font(.system(size: 28))
                            
                            Text("CALM")
                                .font(Theme.Typography.poppins(.bold, size: 11))
                                .foregroundColor(Color(hex: "#1E40AF"))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color(hex: "#DBEAFE"))
                                .clipShape(Capsule())
                            
                            Text("⏱ 1–2 min")
                                .font(Theme.Typography.poppins(.medium, size: 11))
                                .foregroundColor(Theme.Colors.textSecondary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color(hex: "#F1F5F9"))
                                .clipShape(Capsule())
                        }
                        
                        Text("Keep a Photo Close")
                            .font(Theme.Typography.poppins(.bold, size: 26))
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        Text("Look at someone you love and let the warmth settle in. Your smart vagus nerve responds to feelings of connection.")
                            .font(Theme.Typography.poppins(.regular, size: 14))
                            .foregroundColor(Theme.Colors.textSecondary)
                            .lineSpacing(2)
                    }
                    .padding(.top, Theme.Spacing.headerTitleSpacing)
                    
                    // Upload Card
                    VStack(spacing: 14) {
                        Button(action: {
                            hasUploadedPhoto = true
                        }) {
                            VStack(spacing: 8) {
                                Image(systemName: hasUploadedPhoto ? "checkmark.circle.fill" : "plus")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(Theme.Colors.primary)
                                
                                Text(hasUploadedPhoto ? "Photo Selected" : "Tap to upload a photo")
                                    .font(Theme.Typography.poppins(.medium, size: 13.5))
                                    .foregroundColor(Theme.Colors.primary)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 120)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                                    .foregroundColor(Theme.Colors.primary.opacity(0.6))
                                    .background(Color(hex: "#EFF6FF").opacity(0.5))
                            )
                        }
                        .buttonStyle(.plain)
                        
                        Text("Choose a photo of someone or something you love dearly — a partner, family member, pet, friend, or a special moment together.")
                            .font(Theme.Typography.poppins(.regular, size: 13))
                            .foregroundColor(Theme.Colors.textSecondary)
                            .lineSpacing(2)
                        
                        Button(action: {
                            hasUploadedPhoto = true
                        }) {
                            Text("Choose from Camera Roll")
                                .font(Theme.Typography.poppins(.semiBold, size: 14))
                                .foregroundColor(Theme.Colors.primary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(Color(hex: "#EFF6FF"))
                                .cornerRadius(12)
                        }
                    }
                    .padding(18)
                    .background(Color.white)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color(hex: "#E2E8F0"), lineWidth: 1)
                    )
                    
                    // Reflection Prompts Card
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Once you've uploaded your photo")
                            .font(Theme.Typography.poppins(.bold, size: 15))
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            promptRow(text: "Look at the photo for 1–2 minutes")
                            promptRow(text: "Think about a happy memory you share with this person or being")
                            promptRow(text: "Notice any warmth, calm, or connection you feel in your body")
                        }
                        
                        Text("Save this photo somewhere easy to find — your lock screen, wallet, or favorites — so it's always there when you need it.")
                            .font(Theme.Typography.poppins(.regular, size: 12.5))
                            .foregroundColor(Theme.Colors.textSecondary)
                            .lineSpacing(2)
                    }
                    .padding(18)
                    .background(Color.white)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color(hex: "#E2E8F0"), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            
            // Pinned Bottom Actions
            VStack(spacing: 8) {
                PrimaryButton(
                    title: "Complete Exercise",
                    action: {
                        router?.navigate(to: .exerciseComplete)
                    }
                )
                
                Button(action: {
                    router?.pop()
                }) {
                    Text("Cancel")
                        .font(Theme.Typography.poppins(.medium, size: 15))
                        .foregroundColor(Theme.Colors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.white.ignoresSafeArea(edges: .bottom))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background.ignoresSafeArea())
    }
    
    @ViewBuilder
    private func promptRow(text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text("❤️")
                .font(.system(size: 14))
                .padding(.top, 1)
            Text(text)
                .font(Theme.Typography.poppins(.medium, size: 13.5))
                .foregroundColor(Theme.Colors.textPrimary)
                .lineSpacing(2)
        }
    }
}

#Preview {
    KeepPhotoExerciseView()
}
