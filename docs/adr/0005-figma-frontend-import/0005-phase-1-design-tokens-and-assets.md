# ADR 0005.1: Phase 1 — Design Tokens, Typography & Asset Extraction

* **Status**: Accepted
* **Date**: 2026-08-26
* **Deciders**: Lead AI Systems Architect & Mobile Engineering Team

---

## 1. Architectural Context & Scope

To achieve 1:1 visual fidelity with the Figma design (`4uqL8l0VygkDoFQeXP7VeL`), the native SwiftUI app must systematically define global design tokens under `ios/CAREApp/Theme/` and asset catalogs in `ios/CAREApp/Assets.xcassets/` rather than scattering hardcoded values across views.

### Architectural Deliverables
1. **Color Tokens (`Theme/Colors.swift`)**: Semantic surface, background, border, safety status (Low, Medium, High risk), and brand gradient definitions.
2. **Typography Tokens (`Theme/Typography.swift`)**: Dynamic Type–compatible standard typography scale (`largeTitle`, `title1`, `headline`, `body`, `caption`).
3. **Spacing Tokens (`Theme/Spacing.swift`)**: 8-point base grid system (`4pt` to `32pt`) and corner radius constants (`cardRadius: 16pt`, `pillRadius: 24pt`).
4. **Asset Catalog (`Assets.xcassets`)**: Vector SVG assets (`Logo Image`, streak icon, navigation chevrons, safety status icons).

---

## 2. SOTA Test Specification Matrix (Spec-Driven Development)

All assertions in this matrix must be implemented in `ios/CAREAppTests/ThemeTests/` as failing tests prior to implementing `Theme/`:

| Test ID | Test Type | Target Scope | Preconditions (Arrange) | Execution (Act) | Acceptance Criteria & Invariants (Assert) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`TEST-TOK-01`** | Unit / A11y | `Theme.Colors` | Background & text color token pairs | Compute WCAG 2.1 luminosity contrast ratio | `#expect(contrastRatio >= 4.5)` for body text and `#expect(contrastRatio >= 3.0)` for large titles across Light and Dark appearance modes. |
| **`TEST-TOK-02`** | Unit / Logic | `Theme.Colors.Safety` | Safety status color tokens (`lowRisk`, `moderateRisk`, `highRisk`, `neutral`) | Retrieve hex/RGB values | Colors are distinct (`lowRisk != highRisk`), non-nil, and properly map to Green, Amber, Red, Slate ranges. |
| **`TEST-TOK-03`** | Unit / Typography | `Theme.Typography` | Standard font styles (`title`, `headline`, `body`) | Query `UIFontMetrics` scaling across `.extraSmall` and `.accessibilityExtraExtraExtraLarge` | Font size scales monotonically with Dynamic Type categories; line heights prevent text clipping. |
| **`TEST-TOK-04`** | Unit / Layout | `Theme.Spacing` | 8-point grid tokens (`xxSmall` through `xLarge`) | Inspect numeric float values | Every spacing token is a strict integer multiple of 4 (`token.truncatingRemainder(dividingBy: 4) == 0`). |
| **`TEST-TOK-05`** | Unit / Assets | `Assets.xcassets` | Required image asset keys (`care_logo`, `streak_flame`, `chevron_right`) | Load via `UIImage(named: in: nil)` | Image exists, is non-nil, and has valid vector/PDF rendering metadata. |

---

## 3. Executable Test Contract (Swift Testing Spec)

```swift
import Testing
import SwiftUI
@testable import CAREApp

@Suite("Phase 1: Design Tokens & Assets Test Suite")
struct DesignTokensTests {
    
    @Test("TEST-TOK-01: Color tokens satisfy WCAG AA contrast requirements")
    func testColorContrastRatios() {
        let textColors = [Theme.Colors.textPrimary, Theme.Colors.textSecondary]
        let background = Theme.Colors.background
        
        for text in textColors {
            let ratio = ColorUtils.contrastRatio(foreground: text, background: background)
            #expect(ratio >= 4.5, "Text color failed minimum 4.5:1 WCAG AA contrast ratio")
        }
    }
    
    @Test("TEST-TOK-02: Safety status palette defines distinct risk tiers")
    func testSafetyStatusPalette() {
        #expect(Theme.Colors.Safety.lowRisk != Theme.Colors.Safety.highRisk)
        #expect(Theme.Colors.Safety.moderateRisk != Theme.Colors.Safety.lowRisk)
    }

    @Test("TEST-TOK-04: Spacing tokens conform to 8-point grid")
    func testSpacingGridInvariants() {
        let spacings = [Theme.Spacing.xxSmall, Theme.Spacing.xSmall, Theme.Spacing.small, Theme.Spacing.medium, Theme.Spacing.large, Theme.Spacing.xLarge]
        for space in spacings {
            #expect(space.truncatingRemainder(dividingBy: 4) == 0, "Spacing \(space) is not an 8-point grid multiple")
        }
    }
    
    @Test("TEST-TOK-05: Critical asset catalog vector assets are present and loadable")
    func testAssetCatalogIntegrity() {
        let assetNames = ["care_logo", "icon_streak", "icon_chevron_back"]
        for asset in assetNames {
            #expect(UIImage(named: asset) != nil, "Missing critical vector asset: \(asset)")
        }
    }
}
```

---

## 4. SDD Verification Loop Harness

To verify the Red -> Green cycle autonomously:
```bash
xcodebuild test \
  -project ios/CAREApp.xcodeproj \
  -scheme CAREApp \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -only-testing:CAREAppTests/DesignTokensTests
```
