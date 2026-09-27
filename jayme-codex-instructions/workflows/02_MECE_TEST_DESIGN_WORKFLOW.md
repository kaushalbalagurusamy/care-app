# Workflow 02: MECE Test Suite Design & TDD Specification

This workflow establishes the **Test-Driven Development (TDD)** requirements that Codex must follow for any feature or routing change before authoring production code.

---

## 1. The MECE Test-Ladder Constraint

Tests must be designed bottom-up to cover all logical boundaries without gaps or overlap:

```
┌─────────────────────────────────────────────────────────────┐
│ Layer 4: Screen View State Tests                            │
│ (Verify view model bindings, user interaction triggers)     │
└──────────────────────────────┬──────────────────────────────┘
                               ▼
┌─────────────────────────────────────────────────────────────┐
│ Layer 3: Router & Navigation Tests (AppRouterTests.swift)   │
│ (Verify route push, pop, popToRoot, stack state)            │
└──────────────────────────────┬──────────────────────────────┘
                               ▼
┌─────────────────────────────────────────────────────────────┐
│ Layer 2: Reusable UI Component Tests                        │
│ (Verify button actions, cards, theme token compliance)      │
└──────────────────────────────┬──────────────────────────────┘
                               ▼
┌─────────────────────────────────────────────────────────────┐
│ Layer 1: Domain Models & Algorithm Tests                    │
│ (Verify struct decoding, validation rules, state machine)   │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. Test File Placement Standards

* **Domain & Model Tests**: `ios/CAREAppTests/ModelTests/`
* **UI Component Tests**: `ios/CAREAppTests/ComponentTests/`
* **Navigation & Router Tests**: `ios/CAREAppTests/NavigationTests/AppRouterTests.swift`
* **Screen View Tests**: `ios/CAREAppTests/ScreenTests/`

---

## 3. Writing Swift Testing Test Cases

CARE App uses Apple's modern **Swift Testing** framework (`import Testing`):

```swift
import Testing
@testable import CAREApp

@Suite("Feature: Post-Quiz Reflection Flow")
struct ReflectionNavigationTests {

    @Test("TEST-REFLECT-01: AppRouter pushes reflection route cleanly")
    func testRoutePush() {
        let router = AppRouter()
        router.navigate(to: .reflectionCheckin)
        #expect(router.currentRoute == .reflectionCheckin)
        #expect(router.path.count == 1)
    }

    @Test("TEST-REFLECT-02: Pop returns user to quiz view")
    func testRoutePop() {
        let router = AppRouter()
        let sampleTopic = EducationTopic.clinicalTopics[0]
        router.navigate(to: .educationQuiz(topic: sampleTopic))
        router.navigate(to: .reflectionCheckin)
        
        router.pop()
        #expect(router.currentRoute == .educationQuiz(topic: sampleTopic))
    }
}
```

---

## 4. The Red Phase Verification

Before touching production files:
1. Run the test runner:
   ```bash
   ./jayme-codex-instructions/tooling/test_and_eval.sh CAREAppTests/ReflectionNavigationTests
   ```
2. Confirm the tests fail or fail to compile because the route does not yet exist.
3. Once red state is confirmed, proceed to implementation!
