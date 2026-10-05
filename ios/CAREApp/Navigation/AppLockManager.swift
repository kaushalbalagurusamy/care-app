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
    @ObservationIgnored private let sharedStore: UserDraftStore?
    private var enabled: Bool
    
    public var isAppLockEnabled: Bool {
        get { enabled }
        set { enabled = newValue; if sharedStore == nil { UserDefaults.standard.set(newValue, forKey: userDefaultsKey) } }
    }
    
    public init(
        biometricService: any BiometricAuthServiceProtocol = BiometricAuthService(),
        initiallyLocked: Bool? = nil,
        sharedStore: UserDraftStore? = nil
    ) {
        self.biometricService = biometricService
        self.sharedStore = sharedStore
        let isIsolatedUITest = ProcessInfo.processInfo.arguments.contains { $0.hasPrefix("--uitesting-") }
        let legacyEnabled = !isIsolatedUITest && UserDefaults.standard.bool(forKey: userDefaultsKey)
        let storedEnabled: Bool?
        let readFailed: Bool
        do {
            storedEnabled = try sharedStore?.loadValue(Bool.self, key: userDefaultsKey)
            readFailed = false
        } catch {
            storedEnabled = nil
            readFailed = true
        }
        let initialEnabled: Bool
        if readFailed {
            initialEnabled = true
        } else if let stored = storedEnabled {
            initialEnabled = stored
            if !isIsolatedUITest { UserDefaults.standard.removeObject(forKey: userDefaultsKey) }
        } else {
            initialEnabled = legacyEnabled
            if let sharedStore, legacyEnabled, (try? sharedStore.saveValue(legacyEnabled, key: userDefaultsKey)) != nil {
                if !isIsolatedUITest { UserDefaults.standard.removeObject(forKey: userDefaultsKey) }
            }
        }
        self.enabled = initialEnabled
        let locked = readFailed ? true : (initiallyLocked ?? initialEnabled)
        self.isLocked = locked
        self.isShieldActive = locked
        if readFailed { self.errorMessage = "Security settings could not be opened. Your app is locked to protect your data." }
    }
    
    /// Toggle App Lock with immediate biometric confirmation requirement
    public func setAppLockEnabled(_ enable: Bool) async throws -> Bool {
        if enable {
            // Require user to authenticate first before turning App Lock on
            let success = try await biometricService.authenticate(reason: "Confirm your identity to enable App Lock.")
            if success {
                try sharedStore?.saveValue(true, key: userDefaultsKey)
                isAppLockEnabled = true
                return true
            } else {
                return false
            }
        } else {
            // Require authentication before disabling security
            let success = try await biometricService.authenticate(reason: "Confirm your identity to disable App Lock.")
            if success {
                try sharedStore?.saveValue(false, key: userDefaultsKey)
                isAppLockEnabled = false
                isLocked = false
                isShieldActive = false
                return true
            } else {
                return false
            }
        }
    }

    public func resetAfterErasure() {
        enabled = false
        isLocked = false
        isShieldActive = false
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
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
