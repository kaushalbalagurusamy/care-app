import SwiftUI
import LocalAuthentication

// MARK: - App Lock State & Lifecycle Coordinator (Swift 6 @Observable)
@Observable
@MainActor
public final class AppLockManager {
    public let biometricService: any BiometricAuthServiceProtocol
    
    public var isLocked: Bool
    public var isShieldActive: Bool
    public var isAuthenticating: Bool = false
    public var errorMessage: String? = nil
    
    private let userDefaultsKey = "com.careapp.security.isAppLockEnabled"
    
    public var isAppLockEnabled: Bool {
        get {
            UserDefaults.standard.bool(forKey: userDefaultsKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: userDefaultsKey)
        }
    }
    
    public init(
        biometricService: any BiometricAuthServiceProtocol = BiometricAuthService(),
        initiallyLocked: Bool? = nil
    ) {
        self.biometricService = biometricService
        let enabled = UserDefaults.standard.bool(forKey: userDefaultsKey)
        let locked = initiallyLocked ?? enabled
        self.isLocked = locked
        self.isShieldActive = locked
    }
    
    /// Toggle App Lock with immediate biometric confirmation requirement
    public func setAppLockEnabled(_ enable: Bool) async throws -> Bool {
        if enable {
            // Require user to authenticate first before turning App Lock on
            let success = try await biometricService.authenticate(reason: "Confirm your identity to enable App Lock.")
            if success {
                isAppLockEnabled = true
                return true
            } else {
                return false
            }
        } else {
            // Require authentication before disabling security
            let success = try await biometricService.authenticate(reason: "Confirm your identity to disable App Lock.")
            if success {
                isAppLockEnabled = false
                isLocked = false
                isShieldActive = false
                return true
            } else {
                return false
            }
        }
    }
    
    /// Responds to iOS scene phase transitions for multitasking privacy shielding
    public func handleScenePhaseChange(_ phase: ScenePhase) {
        guard isAppLockEnabled else {
            isLocked = false
            isShieldActive = false
            return
        }
        
        switch phase {
        case .background:
            // Immediately activate privacy shield before iOS captures app snapshot
            isShieldActive = true
            isLocked = true
            
        case .inactive:
            // Preparing to enter background or showing system dialog
            isShieldActive = true
            
        case .active:
            if isLocked {
                Task {
                    await authenticate()
                }
            } else {
                isShieldActive = false
            }
            
        @unknown default:
            break
        }
    }
    
    /// Execute biometric unlock
    public func authenticate() async {
        guard isAppLockEnabled && isLocked else {
            isLocked = false
            isShieldActive = false
            return
        }
        
        guard !isAuthenticating else { return }
        isAuthenticating = true
        errorMessage = nil
        
        do {
            let success = try await biometricService.authenticate(reason: "Unlock CARE App to access your assessments.")
            if success {
                withAnimation(.easeInOut(duration: 0.25)) {
                    isLocked = false
                    isShieldActive = false
                }
            }
        } catch {
            errorMessage = "Authentication failed. Tap below to try again."
        }
        
        isAuthenticating = false
    }
}
