# ADR 0007.2: Phase 2 — SwiftData CloudKit Storage Engine & Capacity Limits

* **Status**: Proposed
* **Date**: 2026-08-28
* **Deciders**: Lead AI Systems Architect & Mobile Engineering Team

---

## 1. Architectural Scope & Deliverables

Phase 2 builds the local persistence engine using SwiftData with Apple Private CloudKit synchronization. It defines the persistent model schema, enforces hardware encryption (`NSFileProtectionComplete`), and implements strict 50-item bounded capacity limits.

### Architectural Deliverables
1. **CloudKit-Compliant Persistent Models (`Models/Persistence/`)**:
   * `StoredContact`: Stores contact name, initials, category, age, creation date.
   * `StoredAssessmentSession`: Stores overall scores, C.A.R.E. domain scores, and relational safety distribution percentages.
   * `StoredParticipantResult`: Stores participant-level scores and C.A.R.E. breakdown values.
2. **Encrypted `ModelContainer` Setup**:
   * Initialized with `NSFileProtectionComplete` (hardware AES-256-GCM/XTS encryption).
   * Configured with `ModelConfiguration(cloudKitDatabase: .private)` targeting `iCloud.com.careapp.CAREApp`.
3. **`LocalDeviceRepository` Implementation**:
   * Production repository executing SwiftData CRUD queries with bounded capacity checks.
4. **Bounded Capacity Limit Guards**:
   * Rolodex ceiling: Maximum 50 contacts.
   * Assessment history ceiling: Maximum 50 completed assessments.

---

## 2. Persistent Model Schema

```swift
import SwiftData
import Foundation

@Model
public final class StoredContact {
    public var id: UUID = UUID()
    public var name: String = ""
    public var initials: String = ""
    public var categoryRaw: String = "partner"
    public var age: Int = 30
    public var createdAt: Date = Date()
    
    public init(id: UUID = UUID(), name: String = "", initials: String = "", categoryRaw: String = "partner", age: Int = 30, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.initials = initials
        self.categoryRaw = categoryRaw
        self.age = age
        self.createdAt = createdAt
    }
}

@Model
public final class StoredAssessmentSession {
    public var id: UUID = UUID()
    public var date: Date = Date()
    public var totalScore: Double = 0.0
    public var overallTierRaw: String = "healthy"
    public var safePercentage: Double = 0.0
    public var moderatePercentage: Double = 0.0
    public var highRiskPercentage: Double = 0.0
    public var calmScore: Double = 0.0
    public var acceptedScore: Double = 0.0
    public var resonantScore: Double = 0.0
    public var energeticScore: Double = 0.0
    
    @Relationship(deleteRule: .cascade)
    public var participants: [StoredParticipantResult]? = []
    
    public init(id: UUID = UUID(), date: Date = Date(), totalScore: Double = 0.0, overallTierRaw: String = "healthy", safePercentage: Double = 0.0, moderatePercentage: Double = 0.0, highRiskPercentage: Double = 0.0, calmScore: Double = 0.0, acceptedScore: Double = 0.0, resonantScore: Double = 0.0, energeticScore: Double = 0.0, participants: [StoredParticipantResult] = []) {
        self.id = id
        self.date = date
        self.totalScore = totalScore
        self.overallTierRaw = overallTierRaw
        self.safePercentage = safePercentage
        self.moderatePercentage = moderatePercentage
        self.highRiskPercentage = highRiskPercentage
        self.calmScore = calmScore
        self.acceptedScore = acceptedScore
        self.resonantScore = resonantScore
        self.energeticScore = energeticScore
        self.participants = participants
    }
}
```

---

## 3. SOTA Test Specification Matrix (`StorageEngineTests.swift`)

| Test ID | Test Type | Target Scope | Preconditions (Arrange) | Execution (Act) | Acceptance Criteria & Invariants (Assert) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`TEST-STO-01`** | Unit | `StoredContact` CRUD | In-memory `ModelContainer` | Insert, query by ID, update name, and delete `StoredContact` | All operations succeed; context saves cleanly without corruption. |
| **`TEST-STO-02`** | Unit | Cascade Deletion | Create session with 5 `StoredParticipantResult` children | Delete parent `StoredAssessmentSession` from container | **Cascade Deletion Invariant**: All 5 participant child records are automatically deleted from storage. |
| **`TEST-STO-03`** | Unit / Contract | CloudKit Invariants | Inspect SwiftData model initializers | Instantiate `StoredContact` and `StoredAssessmentSession` without arguments | All attributes default cleanly without uninitialized optional crashes. |
| **`TEST-STO-04`** | Unit / Guard | Rolodex 50-Item Limit | Pre-populate container with 50 contacts | Attempt to insert 51st contact | **Bounded Ceiling Guard**: Throws `StorageLimitError.contactLimitExceeded(max: 50)`. |
| **`TEST-STO-05`** | Unit / Guard | Assessment 50-Item Limit | Pre-populate container with 50 historical assessment sessions | Save 51st assessment session | **Bounded Ceiling Guard**: Enforces 50-session limit or auto-prunes oldest session. |
| **`TEST-STO-06`** | Benchmark | Storage Footprint | Populate container with max 50 contacts + max 50 complete sessions | Measure serialized byte size | **Footprint Invariant**: Total footprint must measure **strictly $< 500\text{ KB}$**. |

---

## 4. Acceptance Criteria
- [ ] SwiftData schema complies with CloudKit rules (optional relationships, default values).
- [ ] 50-item bounded limits strictly prevent memory and storage bloat.
- [ ] Passes all 6 test assertions (`TEST-STO-01` through `TEST-STO-06`).
