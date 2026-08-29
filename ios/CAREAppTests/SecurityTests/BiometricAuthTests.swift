import Testing
import SwiftUI
@testable import CAREApp

@Suite("Biometric Authentication & App Lock Tests (ADR 0008)")
struct BiometricAuthTests {

    @Test("TEST-BIO-01: Biometric capability detection accurately reports hardware biometry type")
    func testBiometricCapabilityDetection() {
        let faceIDService = MockBiometricAuthService(shouldSucceed: true, mockBiometricType: .faceID, isAvailable: true)
        #expect(faceIDService.biometricType == .faceID)
        #expect(faceIDService.isBiometricsAvailable == true)
        
        let touchIDService = MockBiometricAuthService(shouldSucceed: true, mockBiometricType: .touchID, isAvailable: true)
        #expect(touchIDService.biometricType == .touchID)
        #expect(touchIDService.isBiometricsAvailable == true)
        
        let noneService = MockBiometricAuthService(shouldSucceed: true, mockBiometricType: .none, isAvailable: false)
        #expect(noneService.biometricType == .none)
        #expect(noneService.isBiometricsAvailable == false)
    }

    @Test("TEST-BIO-02: AppLockManager transitions isLocked to false upon successful authentication")
    @MainActor
    func testSuccessfulUnlock() async {
        let mockBio = MockBiometricAuthService(shouldSucceed: true, mockBiometricType: .faceID)
        let manager = AppLockManager(biometricService: mockBio, initiallyLocked: true)
        manager.isAppLockEnabled = true
        manager.isLocked = true
        manager.isShieldActive = true
        
        #expect(manager.isLocked == true)
        #expect(manager.isShieldActive == true)
        
        await manager.authenticate()
        
        #expect(manager.isLocked == false)
        #expect(manager.isShieldActive == false)
        #expect(manager.errorMessage == nil)
    }

    @Test("TEST-BIO-03: AppLockManager remains locked with error message when biometric authentication fails")
    @MainActor
    func testAuthenticationFailure() async {
        let mockBio = MockBiometricAuthService(shouldSucceed: false, mockBiometricType: .faceID)
        let manager = AppLockManager(biometricService: mockBio, initiallyLocked: true)
        manager.isAppLockEnabled = true
        manager.isLocked = true
        manager.isShieldActive = true
        
        await manager.authenticate()
        
        #expect(manager.isLocked == true)
        #expect(manager.isShieldActive == true)
        #expect(manager.errorMessage != nil)
    }

    @Test("TEST-BIO-04: Multitasking privacy shield immediately activates when scenePhase transitions to background")
    @MainActor
    func testScenePhaseBackgroundShielding() {
        let mockBio = MockBiometricAuthService(shouldSucceed: true)
        let manager = AppLockManager(biometricService: mockBio, initiallyLocked: false)
        manager.isAppLockEnabled = true
        manager.isLocked = false
        manager.isShieldActive = false
        
        // App moves to background -> Privacy shield activates
        manager.handleScenePhaseChange(.background)
        #expect(manager.isShieldActive == true)
        #expect(manager.isLocked == true)
        
        // When App Lock is disabled, scenePhase transitions do not lock app
        manager.isAppLockEnabled = false
        manager.handleScenePhaseChange(.active)
        #expect(manager.isShieldActive == false)
        #expect(manager.isLocked == false)
    }

    @Test("TEST-BIO-05: Enabling App Lock requires immediate biometric confirmation before persisting")
    @MainActor
    func testEnableAppLockRequiresBiometrics() async throws {
        let mockBioSuccess = MockBiometricAuthService(shouldSucceed: true)
        let manager = AppLockManager(biometricService: mockBioSuccess, initiallyLocked: false)
        manager.isAppLockEnabled = false
        
        let enabled = try await manager.setAppLockEnabled(true)
        #expect(enabled == true)
        #expect(manager.isAppLockEnabled == true)
        
        let mockBioFailure = MockBiometricAuthService(shouldSucceed: false)
        let manager2 = AppLockManager(biometricService: mockBioFailure, initiallyLocked: false)
        manager2.isAppLockEnabled = false
        
        do {
            _ = try await manager2.setAppLockEnabled(true)
            #expect(manager2.isAppLockEnabled == false)
        } catch {
            #expect(manager2.isAppLockEnabled == false)
        }
    }
}
