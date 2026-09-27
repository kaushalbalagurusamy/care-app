# Skill: Topological Code Implementer

## Objective
Author clean, bug-free Swift 6 / SwiftUI code in strict topological dependency order, adhering to CARE App's design tokens and navigation invariants.

## Order of Authoring
1. `Models/` (Data structs, Codable, Hashable)
2. `Repositories/` or `Services/` (Protocol + Mock)
3. `Components/` (Buttons, Cards, Inputs with `Colors` and `Typography`)
4. `Views/` (Screen assembly with `HeaderNavBar` and `PrimaryButton`)
5. `Navigation/AppRouter.swift` + `ContentView.swift` (Enum case + View destination)

## Invariant Checks
* Did I hide the native navigation bar? `.navigationBarBackButtonHidden(true)`
* Did I use theme tokens instead of raw colors? (`Colors.textPrimary` vs `.black`)
* Does the screen support Dynamic Type and standard padding?
