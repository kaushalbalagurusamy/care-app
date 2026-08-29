# ADR 0008: Biometric Authentication (Face ID / Touch ID) & App Lock Architecture

* **Status**: Completed / Verified
* **Date**: 2026-08-29
* **Deciders**: Lead AI Systems Architect & Mobile Engineering Team

---

## 1. Executive Summary & Problem Statement

CARE App captures sensitive clinical wellness evaluations and relational risk profiles. While data at rest is hardware-encrypted via `NSFileProtectionComplete` (ADR 0007), a user’s physical device may be unlocked and accessed by others.

To provide clinical-grade privacy without compromising user ergonomics, CARE App introduces an **opt-in Biometric App Lock (Face ID / Touch ID / Optic ID)**:
1. **Zero-Knowledge Biometric Authentication**: Powered natively by Apple's `LocalAuthentication` (`LAContext.evaluatePolicy(.deviceOwnerAuthentication, ...)`).
2. **Multitasking App Switcher Privacy Shield**: Automatically blurs/shields application views when moving to the background to prevent sensitive assessment scores from appearing in iOS snapshots.
3. **User-Controlled Lock Settings**: Toggle switch and confirmation challenge accessible in `StorageSettingsView`.

---

## 2. System Architecture & Lifecycle State Machine

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            App Lifecycle (ScenePhase)                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   [App Inactive / Background] ──────► [Display Privacy Shield Overlay]      │
│                │                                    │                       │
│                ▼ (App Foregrounded)                 │                       │
│   [Trigger Face ID Prompt (LAContext)]              │                       │
│                │                                    │                       │
│       ┌────────┴────────┐                           │                       │
│   (Success)         (Failure/Cancel)                │                       │
│       │                 │                           │                       │
│       ▼                 ▼                           ▼                       │
│  [Unlock Views]   [Remain Locked / Prompt Passcode] ──┘                     │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Protocol Contract & Component Specifications

### A. `BiometricAuthServiceProtocol` (`Services/BiometricAuthService.swift`)
```swift
import Foundation
import LocalAuthentication

public enum BiometricType: String, Sendable {
    case faceID = "Face ID"
    case touchID = "Touch ID"
    case opticID = "Optic ID"
    case none = "Passcode"
}

public protocol BiometricAuthServiceProtocol: Sendable {
    var biometricType: BiometricType { get }
    var isBiometricsAvailable: Bool { get }
    func authenticate(reason: String) async throws -> Bool
}
```

### B. `AppLockManager` (`Navigation/AppLockManager.swift`)
* Observes `@Environment(\.scenePhase)`.
* Tracks `isLocked: Bool`, `isShieldActive: Bool`, and `isAppLockEnabled: Bool`.
* Manages unlock presentation and privacy shield overlay (`Views/AppLockView.swift`).

### C. `StorageSettingsView` Integration
* Adds an **App Security & Lock** card with the Face ID / Touch ID toggle.

---

## 4. SOTA Test Specification Matrix (`BiometricAuthTests.swift`)

| Test ID | Test Type | Target Scope | Preconditions (Arrange) | Execution (Act) | Acceptance Criteria & Invariants (Assert) | Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **`TEST-BIO-01`** | Unit | Biometric Capability Detection | Mock `LAContext` with Face ID enrolled | Query `biometricType` | Returns `.faceID` and `isBiometricsAvailable == true`. | ✅ **PASSED** |
| **`TEST-BIO-02`** | Unit | Successful Unlock | App in locked state | Execute `authenticate()` with success mock | `isLocked` transitions to `false`; views become accessible. | ✅ **PASSED** |
| **`TEST-BIO-03`** | Unit | Authentication Failure / Passcode Fallback | App in locked state | User fails biometric scan | `isLocked` remains `true`; error indicates fallback available. | ✅ **PASSED** |
| **`TEST-BIO-04`** | Unit / Lifecycle | Background Shielding | App active and unlocked | Simulate `.background` scenePhase transition | `AppLockManager` immediately triggers privacy shielding. | ✅ **PASSED** |
| **`TEST-BIO-05`** | Unit / Security | Biometric Confirmation on Enable | Toggle App Lock | Challenge user with biometric prompt before saving | Only enables when biometric match succeeds. | ✅ **PASSED** |

---

## 5. Acceptance Criteria
- [x] `NSFaceIDUsageDescription` configured with user-facing clinical privacy explanation.
- [x] App prompts Face ID on launch/resume only when App Lock is enabled by the user.
- [x] Background app switcher screenshot contains zero readable assessment scores.
- [x] Passes all biometric test assertions (`TEST-BIO-01` through `TEST-BIO-05`).
