# Workflow 03: Dependency-Ordered Implementation

To prevent compiler drift, circular references, and broken bindings, Codex must author code in strict **topological dependency order**.

---

## 1. The Implementation Order

```
[ Step 1: Domain Models ] ──► [ Step 2: Repos / Services ] ──► [ Step 3: UI Components ]
                                                                       │
                                                                       ▼
[ Step 5: Router & Dispatcher ] ◄────────── [ Step 4: Screen Views ] ◄─┘
```

### Step 1: Domain Models & Types (`ios/CAREApp/Models/`)
* Define data structs, enums, codable models, and state containers.
* Guarantee conformance to `Hashable`, `Identifiable`, and `Sendable`.

### Step 2: Repositories & Services (`ios/CAREApp/Repositories/` & `Services/`)
* Create protocol-backed interfaces (e.g. `ReflectionRepositoryProtocol`).
* Provide mock repositories for instant preview and simulator testing.

### Step 3: Reusable Atomic UI Components (`ios/CAREApp/Components/`)
* Build modular UI elements adhering strictly to design tokens in `Theme/` (`Colors`, `Typography`, `Spacing`).
* Never hardcode raw hex colors or random padding values.

### Step 4: Screen Views (`ios/CAREApp/Views/`)
* Assemble components into full-screen views.
* Inject `@Environment(AppRouter.self) private var router`.
* Embed standard `HeaderNavBar` with `onBack: { router.pop() }`.
* Apply `.navigationBarBackButtonHidden(true)`.

### Step 5: Router Registration & Dispatcher
* **`AppRouter.swift`**: Add enum case to `public enum AppRoute: Hashable`.
* **`ContentView.swift`**: Add `case .myNewRoute:` to `viewForRoute(_ route: AppRoute)`.

---

## 2. Coding Guidelines for Codex

1. **Design System Adherence**: Always use `Colors.surfaceBackground`, `Colors.brandGreen`, `Typography.headingLarge`, `Spacing.md`, etc.
2. **Swift 6 Concurrency**: Use `@MainActor` on view models and routers.
3. **No Filler Code**: Never leave `TODO`, `fatalError()`, or stub views in production code paths.
