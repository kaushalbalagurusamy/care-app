import Foundation
import LocalAuthentication

// MARK: - Biometric Hardware Type Discovery
public enum BiometricType: String, Sendable, CaseIterable {
    case faceID = "Face ID"
    case touchID = "Touch ID"
    case opticID = "Optic ID"
    case none = "Passcode"
}

// MARK: - Biometric Authentication Service Protocol (Swift 6 & Sendable)
public protocol BiometricAuthServiceProtocol: Sendable {
    var biometricType: BiometricType { get }
    var isBiometricsAvailable: Bool { get }
    func authenticate(reason: String) async throws -> Bool
}

// MARK: - Production Native LocalAuthentication Service
public final class BiometricAuthService: BiometricAuthServiceProtocol, @unchecked Sendable {
    public init() {}
    
    public var biometricType: BiometricType {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }
        
        switch context.biometryType {
        case .faceID:
            return .faceID
        case .touchID:
            return .touchID
        case .opticID:
            return .opticID
        case .none:
            return .none
        @unknown default:
            return .none
        }
    }
    
    public var isBiometricsAvailable: Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    public func authenticate(reason: String = "Unlock CARE App to access your relational safety assessments and contacts.") async throws -> Bool {
        let context = LAContext()
        context.localizedCancelTitle = "Cancel"
        
        var error: NSError?
        // Check if device owner authentication (biometrics + passcode fallback) is possible
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            if let error = error {
                throw error
            }
            return false
        }
        
        return try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason)
    }
}

// MARK: - Mock Biometric Authentication Service for Tests & Previews
public final class MockBiometricAuthService: BiometricAuthServiceProtocol, @unchecked Sendable {
    private let lock = NSLock()
    public var shouldSucceed: Bool
    public var mockBiometricType: BiometricType
    public var isAvailable: Bool
    
    public init(
        shouldSucceed: Bool = true,
        mockBiometricType: BiometricType = .faceID,
        isAvailable: Bool = true
    ) {
        self.shouldSucceed = shouldSucceed
        self.mockBiometricType = mockBiometricType
        self.isAvailable = isAvailable
    }
    
    public var biometricType: BiometricType {
        lock.lock()
        defer { lock.unlock() }
        return mockBiometricType
    }
    
    public var isBiometricsAvailable: Bool {
        lock.lock()
        defer { lock.unlock() }
        return isAvailable
    }
    
    public func authenticate(reason: String = "Unlock App") async throws -> Bool {
        lock.lock()
        defer { lock.unlock() }
        if shouldSucceed {
            return true
        } else {
            throw LAError(.userCancel)
        }
    }
}
