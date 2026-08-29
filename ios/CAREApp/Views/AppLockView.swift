import SwiftUI

// MARK: - App Lock Screen & Multitasking Privacy Shield Overlay
public struct AppLockView: View {
    @Environment(AppEnvironment.self) private var appEnvironment
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Theme.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: Theme.Spacing.large) {
                Spacer()
                
                // Branded App Lock Emblem
                ZStack {
                    Circle()
                        .fill(Theme.Colors.cardSurface)
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "lock.fill")
                        .font(.system(size: 42, weight: .semibold))
                        .foregroundColor(Theme.Colors.primary)
                }
                
                VStack(spacing: Theme.Spacing.small) {
                    Text("CARE App Locked")
                        .font(Theme.Typography.welcomeTitle)
                        .foregroundColor(Theme.Colors.textPrimary)
                    
                    Text("Your relational assessments and contacts are encrypted. Authenticate to continue.")
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Theme.Spacing.large)
                }
                
                if let error = appEnvironment.appLockManager.errorMessage {
                    Text(error)
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.Safety.highRisk)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Theme.Spacing.large)
                }
                
                Spacer()
                
                // Unlock Button
                Button(action: {
                    Task {
                        await appEnvironment.appLockManager.authenticate()
                    }
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: biometricIconName)
                            .font(.system(size: 20, weight: .semibold))
                        
                        Text("Unlock with \(appEnvironment.appLockManager.biometricService.biometricType.rawValue)")
                            .font(Theme.Typography.cardTitle)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: Theme.Dimensions.primaryButtonHeight)
                    .background(Theme.Colors.primary)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, Theme.Spacing.large)
                .padding(.bottom, Theme.Spacing.xxLarge)
            }
        }
    }
    
    private var biometricIconName: String {
        switch appEnvironment.appLockManager.biometricService.biometricType {
        case .faceID:
            return "faceid"
        case .touchID:
            return "touchid"
        case .opticID:
            return "opticid"
        case .none:
            return "key.fill"
        }
    }
}
