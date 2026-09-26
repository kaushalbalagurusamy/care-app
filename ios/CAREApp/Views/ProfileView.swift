import SwiftUI

// MARK: - Screen 22: Profile Page View (Figma Frame 218:4)
public struct ProfileView: View {
    public let router: AppRouter
    
    @State private var fullName: String = "Alex Johnson"
    @State private var age: String = "28"
    @State private var selectedFrequency: String = "biweekly"
    
    let frequencies = [
        "2x/week",
        "1x/week",
        "biweekly",
        "monthly",
        "every 3 months"
    ]
    
    public init(router: AppRouter) {
        self.router = router
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            HeaderNavBar(
                showBackButton: true,
                showHomeButton: true,
                showSparkleButton: true,
                sparklePlacement: .right,
                title: nil
            )
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Title
                    VStack(alignment: .leading, spacing: 6) {
                        Text("My Profile")
                            .font(Theme.Typography.poppins(.bold, size: 30))
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        Text("Manage your personal details and assessment schedule")
                            .font(Theme.Typography.poppins(.regular, size: 15))
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                    .padding(.top, 4)
                    
                    // Profile Photo
                    VStack(spacing: 8) {
                        Circle()
                            .fill(Theme.Colors.primary.opacity(0.12))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 36))
                                    .foregroundColor(Theme.Colors.primary)
                            )
                        
                        Text("Change Profile Photo")
                            .font(Theme.Typography.poppins(.medium, size: 13))
                            .foregroundColor(Theme.Colors.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    
                    // Form Fields
                    VStack(alignment: .leading, spacing: 14) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Full Name")
                                .font(Theme.Typography.poppins(.semiBold, size: 14))
                                .foregroundColor(Theme.Colors.textPrimary)
                            
                            TextField("Full Name", text: $fullName)
                                .font(Theme.Typography.poppins(.regular, size: 15))
                                .padding(.horizontal, 14)
                                .frame(height: 48)
                                .background(Theme.Colors.surfaceSecondary)
                                .cornerRadius(12)
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Age")
                                .font(Theme.Typography.poppins(.semiBold, size: 14))
                                .foregroundColor(Theme.Colors.textPrimary)
                            
                            TextField("Age", text: $age)
                                .font(Theme.Typography.poppins(.regular, size: 15))
                                .keyboardType(.numberPad)
                                .padding(.horizontal, 14)
                                .frame(height: 48)
                                .background(Theme.Colors.surfaceSecondary)
                                .cornerRadius(12)
                        }
                    }
                    
                    // Assessment Frequency
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Target Assessment Frequency")
                            .font(Theme.Typography.poppins(.semiBold, size: 14))
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        HStack(spacing: 8) {
                            ForEach(frequencies.prefix(3), id: \.self) { freq in
                                frequencyPill(freq)
                            }
                        }
                        HStack(spacing: 8) {
                            ForEach(frequencies.suffix(2), id: \.self) { freq in
                                frequencyPill(freq)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            
            // Bottom Stacked Actions
            VStack(spacing: 10) {
                Divider()
                    .background(Theme.Colors.dividerSubtle)
                
                Button(action: {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    router.pop()
                }) {
                    Text("Save Changes")
                        .font(Theme.Typography.buttonLabel)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Theme.Colors.primary)
                        .cornerRadius(28)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .accessibilityIdentifier("SaveChangesButton")
                
                Button(action: {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    router.pop()
                }) {
                    Text("Cancel")
                        .font(Theme.Typography.poppins(.medium, size: 16))
                        .foregroundColor(Theme.Colors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
                .accessibilityIdentifier("ProfileCancelButton")
            }
            .background(Theme.Colors.background)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background.ignoresSafeArea())
    }
    
    @ViewBuilder
    private func frequencyPill(_ freq: String) -> some View {
        Button(action: {
            selectedFrequency = freq
        }) {
            Text(freq)
                .font(Theme.Typography.poppins(.medium, size: 13))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .foregroundColor(selectedFrequency == freq ? .white : Theme.Colors.textPrimary)
                .background(selectedFrequency == freq ? Theme.Colors.primary : Theme.Colors.cardSurface)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(selectedFrequency == freq ? Theme.Colors.primary : Theme.Colors.dividerSubtle, lineWidth: 1)
                )
        }
    }
}

// MARK: - Previews
#Preview("Profile View") {
    ProfileView(router: AppRouter())
}
