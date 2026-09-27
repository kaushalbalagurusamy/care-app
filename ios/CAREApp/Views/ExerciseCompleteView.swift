import SwiftUI

// MARK: - Screen: Exercise Complete Celebration (Figma Frame 290:4 & Node 239:8)
public struct ExerciseCompleteView: View {
    @Environment(AppRouter.self) private var router: AppRouter?
    @State private var selectedRating: Int = 4
    
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
                VStack(spacing: 20) {
                    
                    // Celebration Header
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "#EFF6FF"))
                                .frame(width: 80, height: 80)
                            
                            Circle()
                                .stroke(Theme.Colors.primary, lineWidth: 3)
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "checkmark")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(Theme.Colors.primary)
                        }
                        .padding(.top, Theme.Spacing.headerTitleSpacing)
                        
                        VStack(spacing: 4) {
                            Text("Exercise Complete!")
                                .font(Theme.Typography.poppins(.bold, size: 26))
                                .foregroundColor(Theme.Colors.textPrimary)
                            
                            Text("Watch Something Funny")
                                .font(Theme.Typography.poppins(.medium, size: 15))
                                .foregroundColor(Theme.Colors.textSecondary)
                        }
                    }
                    
                    // Stats 3-Item Card
                    HStack(spacing: 0) {
                        statColumn(value: "6", label: "Completed")
                        Divider().frame(height: 36)
                        statColumn(value: "3 days", label: "Streak 🔥")
                        Divider().frame(height: 36)
                        statColumn(value: "Sep 22", label: "Last Done")
                    }
                    .padding(.vertical, 14)
                    .background(Color(hex: "#F8FAFC"))
                    .cornerRadius(18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color(hex: "#E2E8F0"), lineWidth: 1)
                    )
                    
                    // Rating Section
                    VStack(spacing: 10) {
                        Text("How helpful was this exercise?")
                            .font(Theme.Typography.poppins(.semiBold, size: 14))
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        HStack(spacing: 12) {
                            ForEach(1...5, id: \.self) { star in
                                Button(action: {
                                    let generator = UIImpactFeedbackGenerator(style: .light)
                                    generator.impactOccurred()
                                    selectedRating = star
                                }) {
                                    Image(systemName: star <= selectedRating ? "star.fill" : "star")
                                        .font(.system(size: 26))
                                        .foregroundColor(Color(hex: "#F59E0B"))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color(hex: "#E2E8F0"), lineWidth: 1)
                    )
                    
                    // Try Next Card
                    VStack(alignment: .leading, spacing: 10) {
                        Text("TRY NEXT")
                            .font(Theme.Typography.poppins(.bold, size: 11))
                            .foregroundColor(Theme.Colors.textSecondary)
                        
                        HStack(spacing: 12) {
                            Text("📷")
                                .font(.system(size: 24))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Keep a Photo Close")
                                    .font(Theme.Typography.poppins(.semiBold, size: 14.5))
                                    .foregroundColor(Theme.Colors.textPrimary)
                                Text("Ground yourself with an image of someone you love")
                                    .font(Theme.Typography.poppins(.regular, size: 12))
                                    .foregroundColor(Theme.Colors.textSecondary)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                router?.navigate(to: .keepPhoto)
                            }) {
                                Text("Try")
                                    .font(Theme.Typography.poppins(.semiBold, size: 13))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Theme.Colors.primary)
                                    .clipShape(Capsule())
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
            
            // Bottom Buttons Group
            VStack(spacing: 10) {
                PrimaryButton(
                    title: "View All Exercises",
                    action: {
                        router?.navigate(to: .calmExercises)
                    }
                )
                
                SecondaryButton(
                    title: "Return to Home",
                    icon: "house.fill",
                    action: {
                        router?.popToRoot()
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
    private func statColumn(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(Theme.Typography.poppins(.bold, size: 16))
                .foregroundColor(Theme.Colors.textPrimary)
            Text(label)
                .font(Theme.Typography.poppins(.regular, size: 11.5))
                .foregroundColor(Theme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ExerciseCompleteView()
}
