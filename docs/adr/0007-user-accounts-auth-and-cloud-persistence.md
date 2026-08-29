# ADR 0007: Local-First Encrypted Storage, iCloud Sync & Notification Architecture

* **Status**: Completed / Verified
* **Date**: 2026-08-28 (Updated 2026-08-29)
* **Deciders**: Lead AI Systems Architect & Mobile Engineering Team

---

## 1. Executive Summary & Context

With the successful completion of the 10 Figma UI frames (ADR 0005.1 through 0005.5), the CARE App frontend features a verified visual baseline. The application is transitioning from in-memory prototype fixtures into a production clinical wellness system.

To maximize user privacy, eliminate third-party cloud infrastructure costs, and provide seamless multi-device continuity, CARE App adopts a **pure local-first, zero-knowledge storage paradigm backed by Apple Private CloudKit Synchronization**:

* **Hardware Encryption & Privacy**: All relationship scores and assessments reside in SQLite/SwiftData containers encrypted with Apple silicon hardware encryption (`NSFileProtectionComplete` / AES-256). Multi-device continuity is powered by End-to-End Encrypted (E2EE) Private CloudKit databases via Apple Advanced Data Protection (ADP).
* **Bounded Storage Footprint**: Enforces strict capacity limits (up to 50 contacts, up to 50 historical assessments) guaranteeing a total footprint **under 0.5 MB ($< 500\text{ KB}$)**.
* **User Storage Management & Erasure**: First-class user controls to swipe-to-delete contacts, delete historical assessments, or trigger a one-tap full data zeroization.
* **Offline Local Notifications**: Bi-weekly assessment reminders operate completely on-device via `UNUserNotificationCenter` without external push servers.

---

## 2. Architecture & The 4 System Pillars

```
┌─────────────────────────────────────────────────────────────────────────┐
│                       SwiftUI Views (Frames 1–10)                       │
│      (HomeView, ChooseRelationshipsView, SurveyView, PastResultsView)   │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │ (Dependency Injection)
                                     ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                          Repository Layer                               │
│  ┌───────────────────────────┐         ┌─────────────────────────────┐  │
│  │ AssessmentRepositoryProto │         │ ContactsRepositoryProtocol  │  │
│  └─────────────┬─────────────┘         └──────────────┬──────────────┘  │
│                │                                      │                 │
│                ▼                                      ▼                 │
│  ┌───────────────────────────────────────────────────────────────────┐  │
│  │                    LocalDeviceRepository                          │  │
│  └───────────────────────────────────────────────────────────────────┘  │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────┐
│            Local Hardware-Encrypted Storage (SwiftData / SQLite)        │
│  - AES-256-GCM / XTS Hardware Encryption (NSFileProtectionComplete)     │
│  - Bounded Capacity: Max 50 Contacts, Max 50 Historical Assessments     │
│  - User Storage Management: Swipe-to-Delete & Full Purge Actions        │
│  - Local Notification Engine: UNUserNotificationCenter (Bi-Weekly)      │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │ (Silent Background Sync)
                                     ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                User Private iCloud Container (CloudKit)                 │
│  - Zero Third-Party Backend Infrastructure Costs                        │
│  - End-to-End Encryption via Apple Advanced Data Protection (ADP)       │
│  - Multi-Device Continuity: iPhone ↔ iPad ↔ Mac                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Back-of-the-Envelope Storage Footprint

```
┌──────────────────────────────────────┬──────────────────────┬──────────────────────┐
│ Entity / Component                   │ Per-Item Size        │ 50-Item Total        │
├──────────────────────────────────────┼──────────────────────┼──────────────────────┤
│ 1. Contacts Rolodex (50 contacts)    │ ~100 bytes           │ ~5 KB                │
│ 2. Assessment Summaries (50 sessions)│ ~480 bytes           │ ~24 KB               │
│ 3. Question Answers (100 answers/ea) │ ~2.0 KB              │ ~100 KB              │
│ 4. SwiftData / SQLite B-Tree Index   │ Overhead & WAL log   │ ~150 KB              │
├──────────────────────────────────────┼──────────────────────┼──────────────────────┤
│ TOTAL USER DATA FOOTPRINT            │                      │ ~279 KB (< 0.3 MB!)  │
└──────────────────────────────────────┴──────────────────────┴──────────────────────┘
```

---

## 4. Modular Sub-ADR Phase Breakdown (SOTA Context-Bounded Execution)

To maintain strict context isolation, deterministic testing, and high-fidelity implementation, Phase 6 is partitioned into 5 self-contained sub-ADRs:

| Phase ADR | Focus Scope | Key Deliverables & Test Suites | Status |
| :--- | :--- | :--- | :---: |
| [`0007.1: Protocols & DI`](file:///docs/adr/0007-local-storage-and-cloud-sync/0007-phase-1-repository-protocols-and-di.md) | Protocols & Environment | `ContactsRepositoryProtocol`, `AssessmentRepositoryProtocol`, `MockAssessmentRepository`, `AppEnvironment` (`TEST-REP`) | ✅ Completed / Verified |
| [`0007.2: SwiftData & Limits`](file:///docs/adr/0007-local-storage-and-cloud-sync/0007-phase-2-swiftdata-cloudkit-engine-and-limits.md) | Storage Schema & Limits | `StoredContact`, `StoredAssessmentSession`, CloudKit Private DB, 50-Item Guard (`TEST-STO`) | ✅ Completed / Verified |
| [`0007.3: View Wiring & Purge`](file:///docs/adr/0007-local-storage-and-cloud-sync/0007-phase-3-view-wiring-and-storage-management.md) | Views & Deletion Controls | Frame 5 / 10 Wiring, Swipe-to-Delete, Storage Readout Meter, Full Purge (`TEST-MGT`) | ✅ Completed / Verified |
| [`0007.4: Local Notifications`](file:///docs/adr/0007-local-storage-and-cloud-sync/0007-phase-4-biweekly-local-notifications.md) | Bi-Weekly Reminders | `NotificationService`, 14-Day `UNCalendarNotificationTrigger`, In-App Settings (`TEST-NOT`) | ✅ Completed / Verified |
| [`0007.5: Testing & Sync Audit`](file:///docs/adr/0007-local-storage-and-cloud-sync/0007-phase-5-testing-benchmarks-and-audit.md) | Benchmarks & Multi-Device | Multi-Device Sync Fallback, Storage Benchmarks ($< 500\text{ KB}$), Lifecycle & E2E Workflows (`TEST-BENCH`, `TEST-SYNC`, `TEST-E2E`) | ✅ Completed / Verified |

---

## 5. Global 23-Test SOTA Verification Matrix

```
┌────────────────────────────────────────────────────────────────────────────────┐
│                          Phase 6 Test Suite Structure                          │
├────────────────────────────────┬───────────────────────────────┬───────────────┤
│ Suite Name                     │ Target Scope                  │ Test Count    │
├────────────────────────────────┼───────────────────────────────┼───────────────┤
│ 1. RepositoryTests             │ Protocol Decoupling & DI      │ 3 tests       │
│ 2. StorageEngineTests          │ SwiftData Models & Limits     │ 6 tests       │
│ 3. StorageManagementTests      │ Deletion & Purge Controls     │ 4 tests       │
│ 4. NotificationServiceTests    │ Bi-Weekly Local Notifications │ 4 tests       │
│ 5. SyncStateTests              │ Multi-Device Sync & Fallbacks │ 3 tests       │
│ 6. StorageUIJourneyTests       │ E2E Swipe Deletion & Settings │ 3 UI tests    │
├────────────────────────────────┴───────────────────────────────┼───────────────┤
│ Total Planned Phase 6 Assertions                               │ 23 Tests      │
└────────────────────────────────────────────────────────────────┴───────────────┘
```
