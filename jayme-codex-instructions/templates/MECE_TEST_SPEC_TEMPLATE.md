# MECE Test Suite Specification: [Feature Name]

* **Associated PRD**: `docs/prd/PRD_[feature_slug].md`
* **Test File**: `ios/CAREAppTests/NavigationTests/[Feature]Tests.swift`

---

## 1. Test Ladder Matrix

| Layer | Test Identifier | Description | Assertion Criteria |
| :--- | :--- | :--- | :--- |
| **Layer 1: Unit / Model** | `TEST-[FEAT]-01` | Validates struct initialization and defaults | `#expect(model.id != nil)` |
| **Layer 2: Component** | `TEST-[FEAT]-02` | Validates button disabled when input empty | `#expect(button.isEnabled == false)` |
| **Layer 3: Router** | `TEST-[FEAT]-03` | Pushing route increments stack count to N | `#expect(router.currentRoute == .[route])` |
| **Layer 4: Stack Pop** | `TEST-[FEAT]-04` | Popping route returns to previous screen | `#expect(router.currentRoute == .[prevRoute])` |

---

## 2. Swift Testing Implementation Scaffold

```swift
import Testing
@testable import CAREApp

@Suite("Feature: [Feature Name] Specification")
struct [Feature]Tests {

    @Test("TEST-[FEAT]-01: Model initializes with valid default parameters")
    func testModelInitialization() async throws {
        // Given
        // When
        // Then
    }

    @Test("TEST-[FEAT]-02: Navigation router transitions forward cleanly")
    func testRouterForward() {
        let router = AppRouter()
        router.navigate(to: .[newRouteName])
        #expect(router.currentRoute == .[newRouteName])
    }

    @Test("TEST-[FEAT]-03: Navigation router pops back cleanly")
    func testRouterBackward() {
        let router = AppRouter()
        router.navigate(to: .home)
        router.navigate(to: .[newRouteName])
        router.pop()
        #expect(router.currentRoute == .home)
    }
}
```
