# ADR 0005.2: Phase 2 — Domain Data Models, Navigation State & Pluggable Scoring Architecture

* **Status**: Accepted
* **Date**: 2026-08-26
* **Deciders**: Lead AI Systems Architect & Mobile Engineering Team

---

## 1. Architectural Context & Scope

The Figma user journey spans 10 interactive states across assessment setup, participant time-frequency calibration, multi-person questionnaire progression, and multi-dimensional results visualization. 

To maintain clean separation of concerns and allow seamless future refinement of clinical scoring formulas, the architecture enforces:
1. **Decoupled Identity vs. Session State**: Separation of the user's permanent address book (`Person`) from transient assessment configurations (`AssessmentParticipant`).
2. **Multi-Domain Flexible Question Mapping**: Each question can map to **one or more** C.A.R.E. categories with custom domain weights.
3. **Pluggable Strategy-Pattern Scoring Engine**: Scoring algorithms and domain point maximums (e.g. $125\text{ pt}$ max or dynamic scales) are decoupled from view logic and injected via a configurable strategy.
4. **Deterministic Multi-Person Navigation State Machine**: Orchestrated via a Swift 6 `@Observable` `AppRouter`.

---

### Architectural Deliverables & Data Models

#### A. Master Identity & Relationship Rolodex (`Models/Person.swift`)
* `RelationshipCategory`: Enum (`.partner`, `.family`, `.friend`, `.coworker`, `.custom`).
* `Person`: Identifiable, Hashable entity (`id: UUID`, `name: String`, `initials: String`, `category: RelationshipCategory`, `age: Int`).

#### B. Transient Assessment Session & Participant Calibration (`Models/AssessmentSession.swift`)
* `AssessmentParticipant`: Session wrapper containing `person: Person` and `percentTimeSpent: Double` ($0.0 \dots 1.0$).
* `ContactFrequencyTier`: Enum (`.daily`, `.weekly`, `.monthly`, `.rarely`).

#### C. Pluggable Multi-Domain Questions & Answers (`Models/SurveyQuestions.swift`)
* `CAREDomain`: Enum (`.calm`, `.accepted`, `.resonant`, `.energetic`) vending letter, title, color token, and neurobiology copy.
* `DomainWeightMapping`: Struct (`domain: CAREDomain`, `weightMultiplier: Double`).
* `SurveyOption`: Struct (`id: String`, `text: String`, `rawScoreValue: Double`).
* `SurveyQuestion`: Struct (`id: String`, `prompt: String`, `targetDomains: [DomainWeightMapping]`, `options: [SurveyOption]`).
* `SurveyAnswer`: Struct (`participantId: UUID`, `questionId: String`, `selectedOption: SurveyOption`, `timestamp: Date`).

#### D. Pluggable Scoring Strategy & Result Entities (`Models/ScoringEngine.swift` & `Models/AssessmentResult.swift`)
* `SafetyTier`: Enum (`.healthy` $\ge 75$, `.moderate` $60-74$, `.highRisk` $< 60$).
* `DomainScoreBreakdown`: Struct (`domain: CAREDomain`, `earnedPoints: Double`, `maxPossiblePoints: Double`, `vagalToneStatus: String?`).
* `RelationalSafetyDistribution`: Struct (`safePercentage: Double`, `moderatePercentage: Double`, `highRiskPercentage: Double`).
* `IndividualResult`: Struct (`participant: AssessmentParticipant`, `normalizedScore: Double`, `safetyTier: SafetyTier`, `domainBreakdown: [CAREDomain: Double]`).
* `AssessmentResult`: Struct aggregating domain breakdowns, safety distribution, and individual results.
* `ScoringConfiguration`: Struct defining thresholds ($\ge 75$, $60-75$) and domain maximums.
* `FlexibleScoringEngine`: Algorithmic engine implementing `ScoringEngineProtocol`.

#### E. Navigation Router & State Machine (`Navigation/AppRouter.swift`)
* `AppRoute`: Enum (`.home`, `.education`, `.exercises`, `.assessmentOverview`, `.surveyOverview`, `.chooseRelationships`, `.relationshipFrequency`, `.surveyQuestion(participantIndex: Int, questionIndex: Int)`, `.surveyResults`, `.surveyResultsExpanded`, `.pastResults`).
* `AppRouter`: `@Observable` and `@MainActor` class managing `NavigationPath`.

---

## 2. SOTA Test Specification Matrix (Spec-Driven Development)

All assertions in this matrix must be implemented in `ios/CAREAppTests/ModelTests/` and `ios/CAREAppTests/NavigationTests/` prior to implementation:

| Test ID | Test Type | Target Scope | Preconditions (Arrange) | Execution (Act) | Acceptance Criteria & Invariants (Assert) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`TEST-MOD-01`** | Unit / Contract | `SurveyQuestion` | Mock JSON fixture with multi-domain mappings | Execute `JSONDecoder().decode()` | Successfully decodes question mapping to multiple `targetDomains` (`.calm` and `.resonant`) with independent weights. |
| **`TEST-MOD-02`** | Unit / Algorithm | `FlexibleScoringEngine` | Sample answers with multi-domain weights across 5 calibrated participants | Calculate `AssessmentResult` | Output `domainScores` and `individualResults` remain bounded in `[0.0, 100.0]`. Tier classification maps correctly ($\ge 75 \to \text{safe}$, $60-74 \to \text{moderate}$, $< 60 \to \text{highRisk}$). |
| **`TEST-MOD-03`** | Unit / State | `AssessmentSession` | 5 participants, 4 questions per participant | Step through questions for Person 1 | Button title equals `"Next"` on questions 1-3, switches to `"Next: {Person 2 Name}"` on question 4, and equals `"Complete Assessment"` on the final question of Person 5. |
| **`TEST-MOD-04`** | Unit / Selection | `AssessmentConfig` | Address book of 10 `Person` entries | Select 5 entries | `canProceed == true` only when `selectedPersonIds.count == 5`. Selecting 4 or 6 disables progression. |
| **`TEST-NAV-01`** | Unit / Routing | `AppRouter` | Clean router at `.home` | Route through `.education`, `.exercises`, and `.assessmentOverview` | Navigation stack depth advances predictably and `popToRoot()` clears all routes back to root. |

---

## 3. Executable Test Contract (Swift Testing Spec)

```swift
import Testing
import Foundation
@testable import CAREApp

@Suite("Phase 2: Domain Models & Pluggable Scoring Test Suite")
struct DomainModelAndScoringTests {
    
    @Test("TEST-MOD-01: Multi-domain SurveyQuestion JSON decoding verification")
    func testMultiDomainQuestionDecoding() throws {
        let json = """
        {
            "id": "q1",
            "prompt": "How settled do you feel in their presence?",
            "targetDomains": [
                {"domain": "calm", "weightMultiplier": 1.0},
                {"domain": "resonant", "weightMultiplier": 0.5}
            ],
            "options": [
                {"id": "opt1", "text": "Completely grounded", "rawScoreValue": 1.0},
                {"id": "opt2", "text": "Constantly on edge", "rawScoreValue": 0.2}
            ]
        }
        """.data(using: .utf8)!
        
        let question = try JSONDecoder().decode(SurveyQuestion.self, from: json)
        #expect(question.targetDomains.count == 2)
        #expect(question.targetDomains[0].domain == .calm)
        #expect(question.targetDomains[1].domain == .resonant)
    }

    @Test("TEST-MOD-02: FlexibleScoringEngine calculates frequency-weighted distributions")
    func testFlexibleScoringCalculations() {
        let personA = Person(name: "Sarah Mitchell", initials: "SM", category: .partner, age: 32)
        let personB = Person(name: "James Cooper", initials: "JC", category: .friend, age: 28)
        
        let participants = [
            AssessmentParticipant(person: personA, percentTimeSpent: 0.60),
            AssessmentParticipant(person: personB, percentTimeSpent: 0.40)
        ]
        
        let engine = FlexibleScoringEngine()
        let result = engine.computeResult(participants: participants, answers: [], questions: [])
        
        #expect(result.safetyDistribution.safePercentage >= 0.0)
        #expect(result.safetyDistribution.safePercentage <= 1.0)
    }

    @Test("TEST-MOD-03: Multi-person progression vends dynamic button titles")
    func testDynamicButtonTitleProgression() {
        let person1 = Person(name: "Sarah Mitchell", initials: "SM", category: .partner, age: 32)
        let person2 = Person(name: "James Cooper", initials: "JC", category: .friend, age: 28)
        let participants = [AssessmentParticipant(person: person1, percentTimeSpent: 0.5), AssessmentParticipant(person: person2, percentTimeSpent: 0.5)]
        
        var session = AssessmentSessionState(participants: participants, totalQuestionsPerPerson: 4)
        
        #expect(session.currentButtonTitle == "Next")
        session.currentQuestionIndex = 3 // Last question for Person 1
        #expect(session.currentButtonTitle == "Next: James Cooper")
        
        session.currentParticipantIndex = 1
        session.currentQuestionIndex = 3 // Last question for Person 2 (Final)
        #expect(session.currentButtonTitle == "Complete Assessment")
    }
}
```

---

## 4. ADR 0006 Governance & Verification Loop Harness

In accordance with [`ADR 0006`](file:///Users/kaushal/Documents/Github/care-app/docs/adr/0006-autonomous-observability-governance-and-tdd-loop.md):

1. **Pre-Edit Checkpoint**: Snapshot the working tree before creating files:
   ```bash
   git add -A && git commit -m "checkpoint(phase-2-pre-edit): clean working tree before model implementation"
   ```
2. **Layer 1 AST & Type Checking**: Verify static syntax with `swift-mcp` before compiling.
3. **Layer 2 Targeted Unit Test Execution**:
   ```bash
   xcodebuild test \
     -project ios/CAREApp.xcodeproj \
     -scheme CAREApp \
     -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
     -only-testing:CAREAppTests/DomainModelAndScoringTests
   ```
4. **Anti-Blindness Failure Capture**: If an assertion fails twice, write `failure_trace.json` to `<appDataDir>/brain/<conversation-id>/scratch/` before triggering `git reset --hard`.

---

## 5. Green Milestone Transition & Storage Purge

Upon all Phase 2 tests passing (Green Milestone):
1. **Commit Green State**:
   ```bash
   git commit -m "green(phase-2): domain models, pluggable scoring engine, and router verified"
   ```
2. **Ephemeral Scratch Cleanup**: Purge temporary `task-*.log` files and transient attempt traces.
3. **Workspace Purge**: Execute `xcodebuildmcp purge` to clean intermediate compiler cache and prevent `DerivedData/` bloat.
