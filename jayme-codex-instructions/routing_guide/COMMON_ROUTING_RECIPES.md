# CARE App — Common Routing Recipes & Patterns

This reference provides Codex and Jayme with exact recipes for implementing the most frequent routing modifications in **CARE App**.

---

## Recipe 1: Adding a Brand-New Screen & Route

When Jayme asks to create a new screen (e.g. `ReflectionCheckinView`):

### Step 1: Declare the Route Enum Case
File: `ios/CAREApp/Navigation/AppRouter.swift`
```swift
public enum AppRoute: Hashable {
    // ... existing routes
    case reflectionCheckin // <-- Add new route
}
```

### Step 2: Implement the SwiftUI Screen
File: `ios/CAREApp/Views/ReflectionCheckinView.swift`
```swift
import SwiftUI

public struct ReflectionCheckinView: View {
    @Environment(AppRouter.self) private var router
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: Spacing.md) {
            HeaderNavBar(
                title: "Daily Reflection",
                onBack: { router.pop() }
            )
            
            Spacer()
            
            Text("How connected did you feel today?")
                .font(Typography.headingMedium)
                .foregroundColor(Colors.textPrimary)
            
            Spacer()
            
            PrimaryButton(title: "Complete Reflection") {
                router.popToRoot()
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.bottom, Spacing.lg)
        }
        .background(Colors.surfaceBackground.ignoresSafeArea())
    }
}
```

### Step 3: Wire into Route Dispatcher
File: `ios/CAREApp/ContentView.swift`
```swift
@ViewBuilder
private func viewForRoute(_ route: AppRoute) -> some View {
    switch route {
    // ... existing routes
    case .reflectionCheckin:
        ReflectionCheckinView()
    }
}
```

### Step 4: Write Navigation Unit Test
File: `ios/CAREAppTests/NavigationTests/AppRouterTests.swift`
```swift
@Test("TEST-NAV-REFLECTION: Reflection checkin route navigates cleanly")
func testReflectionCheckinNavigation() {
    let router = AppRouter()
    router.navigate(to: .reflectionCheckin)
    #expect(router.currentRoute == .reflectionCheckin)
    #expect(router.path.count == 1)
}
```

---

## Recipe 2: Reordering Screens in an Existing Flow

Example: Jayme wants to route the user to `SurveyResultsV2View` immediately upon finishing question 20 instead of the old results screen.

1. Locate where the transition occurs (e.g., in `ios/CAREApp/Views/SurveyQuestionView.swift` or `ContentView.swift`).
2. Update the completion handler or navigation trigger:
```swift
// Before:
router.navigate(to: .surveyResults)

// After (Reordered to V2):
router.navigate(to: .surveyResultsV2)
```
3. If replacing a screen in the backstack, pop the current route before pushing the new one:
```swift
router.pop()
router.navigate(to: .surveyResultsV2)
```

---

## Recipe 3: Passing State or Arguments to a Route

When a destination screen requires parameters (e.g. an `EducationTopic` or `Person`):

### 1. In `AppRouter.swift`:
```swift
case educationDetail(topic: EducationTopic)
case personSummary(person: Person)
```

### 2. In `ContentView.swift`:
```swift
case .educationDetail(let topic):
    TopicDetailView(router: router, topic: topic)
case .personSummary(let person):
    PersonSummaryView(router: router, person: person)
```

### 3. When Navigating:
```swift
router.navigate(to: .educationDetail(topic: selectedTopic))
```

---

## Recipe 4: Adding an Interstitial Transition Screen

When a delay or transition message is needed between two intensive tasks (e.g. transitioning between participants or calculating survey scores):

```swift
struct TransitionInterstitialView: View {
    @Environment(AppRouter.self) private var router
    let destinationRoute: AppRoute
    
    var body: some View {
        VStack(spacing: Spacing.lg) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Analyzing Relational Dimensions...")
                .font(Typography.bodyLarge)
                .foregroundColor(Colors.textSecondary)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                router.pop() // Replace interstitial
                router.navigate(to: destinationRoute)
            }
        }
    }
}
```

---

## Recipe 5: Modal Sheets vs Stack Navigation

For transient actions (e.g., sort sheets, filters, confirmation dialogs):
* **Do NOT use `AppRoute`** for simple sheets.
* Use SwiftUI's native `.sheet(isPresented:)` or `.confirmationDialog`:
```swift
@State private var isShowingSortSheet = false

var body: some View {
    Button("Sort") { isShowingSortSheet = true }
        .sheet(isPresented: $isShowingSortSheet) {
            RelationshipSortSheet(selectedCriteria: $criteria)
                .presentationDetents([.fraction(0.35)])
        }
}
```
