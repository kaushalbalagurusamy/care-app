# CARE App — Routing Architecture & Navigation Engine

This guide details the navigation architecture of **CARE App**, enabling Codex and Jayme to understand, extend, and refactor routing flows safely and deterministically.

---

## 1. Architectural Overview

CARE App uses modern **Swift 6 `@Observable` NavigationStack architecture**, decoupled into three clean layers:

```
┌─────────────────────────────────────────────────────────────┐
│ 1. Typed Route Declarations                                 │
│    AppRoute Enum (ios/CAREApp/Navigation/AppRouter.swift)   │
└──────────────────────────────┬──────────────────────────────┘
                               ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. Navigation State Coordinator                             │
│    AppRouter (@Observable, @MainActor)                      │
│    - path: [AppRoute] (Navigation stack array)              │
│    - navigate(to: AppRoute)                                 │
│    - pop()                                                  │
│    - popToRoot()                                            │
└──────────────────────────────┬──────────────────────────────┘
                               ▼
┌─────────────────────────────────────────────────────────────┐
│ 3. View Destination Dispatcher                              │
│    ContentView.swift (ios/CAREApp/ContentView.swift)        │
│    - NavigationStack(path: $r.path)                         │
│    - .navigationDestination(for: AppRoute.self)             │
│    - viewForRoute(_ route: AppRoute) -> some View           │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. Core Navigation Components

### Component 1: `AppRoute` Enum ([`AppRouter.swift`](file:///Users/kaushal/Projects/care-app/ios/CAREApp/Navigation/AppRouter.swift))
Every navigable screen in the app is represented as a typed enum case conforming to `Hashable`:

```swift
public enum AppRoute: Hashable {
    case loading
    case home
    case education
    case exercises
    case assessmentOverview
    case surveyOverview
    case chooseRelationships
    case relationshipFrequency
    case personTransition
    case surveyQuestion
    case surveyResults
    case surveyResultsExpanded
    case pastResults
    case educationDetail(topic: EducationTopic)
    case educationQuiz(topic: EducationTopic)
    case welcomeAccountSetup
    case personalizedActionPlan
    case profile
    case careInfo
    case addRelationship
    case calmExercises
    case watchFunny
    case keepPhoto
    case belongingList
    case careResultsExercises
    case exerciseComplete
    case surveyResultsV2
    case pastResultsV2
}
```

### Component 2: `AppRouter` Coordinator
The router is marked `@Observable` and `@MainActor`, making it observable across all SwiftUI views:
* `router.navigate(to: .surveyResultsV2)`: Pushes a new route onto the stack.
* `router.pop()`: Pops the topmost route, returning to the previous screen.
* `router.popToRoot()`: Clears the entire navigation stack and returns to `HomeView`.

### Component 3: `ContentView` Route Dispatcher ([`ContentView.swift`](file:///Users/kaushal/Projects/care-app/ios/CAREApp/ContentView.swift))
The `NavigationStack` in `ContentView` resolves each `AppRoute` to its corresponding SwiftUI view:

```swift
@ViewBuilder
private func viewForRoute(_ route: AppRoute) -> some View {
    switch route {
    case .home:
        HomeView(router: router, activeSession: $activeSession, onDiscardAssessment: { ... })
    case .educationDetail(let topic):
        TopicDetailView(router: router, topic: topic)
    case .calmExercises:
        CalmExercisesView(router: router)
    // ... all other route cases
    }
}
```

---

## 3. How Views Access the Router

Views access the router via SwiftUI's `@Environment`:

```swift
struct MyNewScreenView: View {
    @Environment(AppRouter.self) private var router
    
    var body: some View {
        VStack {
            HeaderNavBar(
                title: "My New Screen",
                onBack: { router.pop() }
            )
            
            Button("Proceed to Results") {
                router.navigate(to: .surveyResultsV2)
            }
        }
    }
}
```

---

## 4. Navigation Invariants for Codex

1. **Exhaustive Matching**: When adding a new route to `AppRoute`, `viewForRoute` in `ContentView.swift` must exhaustively handle the case.
2. **Hashable Conformance**: Any parameters passed inside enum cases (e.g., `(topic: EducationTopic)`) must conform to `Hashable` and `Sendable`.
3. **Hidden System Bars**: All destination views must hide the default Apple navigation bar (`.navigationBarBackButtonHidden(true)`) to maintain design system consistency with CARE App's custom `HeaderNavBar`.
4. **Automated Test Coverage**: Every newly introduced route MUST have a corresponding unit test in `CAREAppTests/NavigationTests/AppRouterTests.swift`.
