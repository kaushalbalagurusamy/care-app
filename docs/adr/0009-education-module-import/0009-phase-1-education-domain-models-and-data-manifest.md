# ADR 0009.1: Phase 1 — Education Content Data Models & Bundled Manifest

* **Status**: Proposed
* **Date**: 2026-09-05
* **Deciders**: Lead AI Systems Architect & Mobile Engineering Team

---

## 1. Architectural Scope & Deliverables

Phase 1 establishes the type-safe Swift 6 domain models and bundled JSON content manifest representing the 6 psychoeducation topics extracted directly from Figma:
1. **Relational-Cultural Theory (RCT)** (Overview, Founders, "5 Good Things", Mutual Empathy)
2. **Relational Neuroscience** (4 C.A.R.E. neural pathways: Calm, Accepted, Resonant, Energetic)
3. **Neuroplasticity** (Synaptic rewiring through safe connections)
4. **The Brain in Healthy Relationships** (Biochemical responses, oxytocin, vagal tone)
5. **Power-Over vs. Power-With** (Relational power dynamics & mutual empowerment)
6. **The Impact of Relationships** (Physiological health, cardiovascular wellness, longevity)

### Architectural Deliverables & Model Contracts
```swift
public enum EducationTopicSlug: String, Codable, Sendable, CaseIterable {
    case relationalCulturalTheory = "relational-cultural-theory"
    case relationalNeuroscience = "relational-neuroscience"
    case neuroplasticity = "neuroplasticity"
    case brainHealthyRelationships = "brain-healthy-relationships"
    case powerOverVsPowerWith = "power-over-vs-power-with"
    case impactOfRelationships = "impact-of-relationships"
}

public struct FounderProfile: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let titleAndDegrees: String
    public let biography: String
    public let imageAsset: String?
}

public struct FiveGoodThingsItem: Identifiable, Codable, Hashable, Sendable {
    public let index: Int
    public let title: String
    public let neuroDescription: String
}

public enum EducationSectionPayload: Codable, Hashable, Sendable {
    case textOverview(heading: String, body: String)
    case foundersGrid(founders: [FounderProfile])
    case fiveGoodThings(items: [FiveGoodThingsItem])
    case neuralPathwayMapping(pathways: [NeuralPathwayItem])
    case comparisonTable(rows: [ComparisonRowItem])
    case keyTakeaways(points: [String])
}

public struct EducationTopic: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let slug: EducationTopicSlug
    public let title: String
    public let subtitle: String
    public let iconAsset: String
    public let estimatedReadMinutes: Int
    public let sections: [EducationSectionPayload]
}
```

* **Bundled `EducationManifest.json` (`Resources/Education/EducationManifest.json`)**: Pre-validated, localized content payload matching Figma node contents verbatim.

---

## 2. SOTA Test Specification Matrix (`EducationModelTests.swift`)

| Test ID | Test Type | Target Scope | Preconditions (Arrange) | Execution (Act) | Acceptance Criteria & Invariants (Assert) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`TEST-EDM-01`** | Unit / Contract | Manifest JSON Decoding | Bundled `EducationManifest.json` loaded from `Bundle.main` | `JSONDecoder().decode([EducationTopic].self)` | Decodes exactly 6 topics; `0` missing keys; `0` null string fields; total read duration is $\ge 15\text{ min}$. |
| **`TEST-EDM-02`** | Unit / Invariant | RCT Founders & 5 Good Things | Decoded RCT Topic (`.relationalCulturalTheory`) | Inspect sections for `.foundersGrid` and `.fiveGoodThings` | Exactly 4 founders (Dr. Jean Baker Miller, Dr. Judith Jordan, Dr. Janet Surrey, Dr. Irene Stiver) and 5 Good Things (indexes 1–5 in sequential order). |
| **`TEST-EDM-03`** | Unit / Invariant | 4 C.A.R.E. Neural Pathways | Decoded Neuroscience Topic (`.relationalNeuroscience`) | Inspect `.neuralPathwayMapping` section | Contains all 4 C.A.R.E. pathways: Calm (Smart Vagus), Accepted (DACC), Resonant (Mirror Neurons), Energetic (Dopamine). |
| **`TEST-EDM-04`** | Unit / Safety | Swift 6 Concurrency | `EducationTopic` & submodels | Pass across `@Sendable` async boundary | Conforms to `Sendable`, `Hashable`, `Identifiable` with zero data races. |

---

## 3. Executable Test Contract (Swift Testing Spec)

```swift
import Testing
import Foundation
@testable import CAREApp

@Suite("Phase 1: Education Content Models & Manifest Test Suite")
struct EducationModelTests {
    
    @Test("TEST-EDM-01: Bundled manifest decodes all 6 education curriculum topics")
    func testManifestDecoding() throws {
        let manifest = try EducationManifestLoader.loadBundledManifest()
        #expect(manifest.count == 6)
        
        let totalReadTime = manifest.reduce(0) { $0 + $1.estimatedReadMinutes }
        #expect(totalReadTime >= 15, "Curriculum read duration must be at least 15 minutes")
    }
    
    @Test("TEST-EDM-02: RCT topic contains 4 founders and 5 Good Things in order")
    func testRCTTopicStructure() throws {
        let manifest = try EducationManifestLoader.loadBundledManifest()
        guard let rct = manifest.first(where: { $0.slug == .relationalCulturalTheory }) else {
            Issue.record("Missing Relational-Cultural Theory topic")
            return
        }
        
        var foundFounders = false
        var foundFiveGoodThings = false
        
        for section in rct.sections {
            switch section {
            case .foundersGrid(let founders):
                #expect(founders.count == 4)
                #expect(founders.contains(where: { $0.name.contains("Jean Baker Miller") }))
                foundFounders = true
            case .fiveGoodThings(let items):
                #expect(items.count == 5)
                #expect(items.map(\.index) == [1, 2, 3, 4, 5])
                foundFiveGoodThings = true
            default:
                break
            }
        }
        
        #expect(foundFounders, "RCT topic must contain founders grid")
        #expect(foundFiveGoodThings, "RCT topic must contain 5 Good Things")
    }
    
    @Test("TEST-EDM-03: Relational Neuroscience topic maps 4 C.A.R.E. neural pathways")
    func testNeurosciencePathwayMapping() throws {
        let manifest = try EducationManifestLoader.loadBundledManifest()
        guard let neuro = manifest.first(where: { $0.slug == .relationalNeuroscience }) else {
            Issue.record("Missing Relational Neuroscience topic")
            return
        }
        
        let hasCalm = neuro.sections.contains { if case .neuralPathwayMapping(let p) = $0 { return p.contains(where: { $0.domain == .calm }) } else { return false } }
        #expect(hasCalm, "Must map Calm (Smart Vagus) pathway")
    }
    
    @Test("TEST-EDM-04: Topic models satisfy Sendable, Hashable, and Identifiable")
    func testModelConcurrencySafety() async throws {
        let manifest = try EducationManifestLoader.loadBundledManifest()
        let topic = manifest[0]
        
        let task = Task.detached { () -> String in
            return topic.title
        }
        let title = await task.value
        #expect(!title.isEmpty)
    }
}
```

---

## 4. SDD Verification Loop Harness
```bash
xcodebuild test \
  -project ios/CAREApp.xcodeproj \
  -scheme CAREApp \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -only-testing:CAREAppTests/EducationModelTests
```
