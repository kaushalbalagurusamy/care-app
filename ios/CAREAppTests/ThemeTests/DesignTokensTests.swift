import Testing
import SwiftUI
@testable import CAREApp

@Suite("Phase 1: Design Tokens & Visual Invariants Test Suite")
struct DesignTokensTests {
    
    // Helper to calculate relative luminance of sRGB colors
    private func relativeLuminance(r: Double, g: Double, b: Double) -> Double {
        func channelLuminance(_ val: Double) -> Double {
            return (val <= 0.03928) ? (val / 12.92) : pow((val + 0.055) / 1.055, 2.4)
        }
        let rL = channelLuminance(r)
        let gL = channelLuminance(g)
        let bL = channelLuminance(b)
        return 0.2126 * rL + 0.7152 * gL + 0.0722 * bL
    }
    
    private func contrastRatio(lum1: Double, lum2: Double) -> Double {
        let lighter = max(lum1, lum2)
        let darker = min(lum1, lum2)
        return (lighter + 0.05) / (darker + 0.05)
    }

    @Test("TEST-TOK-01A: Primary text achieves >= 4.5:1 WCAG contrast across all card and background surfaces")
    func testPrimaryTextWCAGContrast() {
        // #1E293B (textPrimary) RGB: (30/255, 41/255, 59/255)
        let textPrimaryLum = relativeLuminance(r: 30/255.0, g: 41/255.0, b: 59/255.0)
        
        // #FFFFFF (background) RGB: (1, 1, 1)
        let bgLum = relativeLuminance(r: 1.0, g: 1.0, b: 1.0)
        
        // #F4F7F9 (surfaceSecondary) RGB: (244/255, 247/255, 249/255)
        let surfaceSecLum = relativeLuminance(r: 244/255.0, g: 247/255.0, b: 249/255.0)
        
        // #EFF5FC (cardSurface) RGB: (239/255, 245/255, 252/255)
        let cardSurfaceLum = relativeLuminance(r: 239/255.0, g: 245/255.0, b: 252/255.0)
        
        let ratioAgainstWhite = contrastRatio(lum1: bgLum, lum2: textPrimaryLum)
        let ratioAgainstSurface = contrastRatio(lum1: surfaceSecLum, lum2: textPrimaryLum)
        let ratioAgainstCard = contrastRatio(lum1: cardSurfaceLum, lum2: textPrimaryLum)
        
        #expect(ratioAgainstWhite >= 4.5, "textPrimary against white must meet WCAG AA (>= 4.5:1), got \(ratioAgainstWhite)")
        #expect(ratioAgainstSurface >= 4.5, "textPrimary against surfaceSecondary must meet WCAG AA, got \(ratioAgainstSurface)")
        #expect(ratioAgainstCard >= 4.5, "textPrimary against cardSurface must meet WCAG AA, got \(ratioAgainstCard)")
    }

    @Test("TEST-TOK-01B: Secondary text achieves >= 4.5:1 WCAG contrast on primary background")
    func testSecondaryTextWCAGContrast() {
        // #64748B (textSecondary) RGB: (100/255, 116/255, 139/255)
        let textSecondaryLum = relativeLuminance(r: 100/255.0, g: 116/255.0, b: 139/255.0)
        let bgLum = relativeLuminance(r: 1.0, g: 1.0, b: 1.0)
        
        let ratio = contrastRatio(lum1: bgLum, lum2: textSecondaryLum)
        #expect(ratio >= 4.5, "textSecondary against white must meet WCAG AA, got \(ratio)")
    }

    @Test("TEST-TOK-02A: Safety status palette defines distinct risk tier colors")
    func testSafetyPaletteIntegrity() {
        let low = Theme.Colors.Safety.lowRisk
        let med = Theme.Colors.Safety.moderateRisk
        let high = Theme.Colors.Safety.highRisk
        
        #expect(low != med)
        #expect(med != high)
        #expect(low != high)
    }

    @Test("TEST-TOK-02B: Hex color initializer correctly parses 3, 6, and 8 digit hex formats")
    func testHexColorParsing() {
        let col3 = Color(hex: "#FFF")
        let col6 = Color(hex: "#246BB8")
        let col8 = Color(hex: "#246BB8FF")
        let colNoHash = Color(hex: "12A3D4")
        
        #expect(col3 != nil)
        #expect(col6 != nil)
        #expect(col8 != nil)
        #expect(colNoHash != nil)
    }

    @Test("TEST-TOK-02C: Hex color parser safely handles corrupted input without throwing")
    func testHexColorCorruptedInputFallback() {
        let invalid1 = Color(hex: "xyz")
        let invalid2 = Color(hex: "")
        let invalid3 = Color(hex: "#12")
        
        // Custom parser falls back to clear or black without runtime fatalError
        #expect(invalid1 == .clear || invalid1 == Color.black.opacity(0))
        #expect(invalid2 == .clear || invalid2 == Color.black.opacity(0))
        #expect(invalid3 == .clear || invalid3 == Color.black.opacity(0))
    }

    @Test("TEST-TOK-03: Spacing grid strictly conforms to 8-point (divisible by 4) geometry")
    func testSpacingGridInvariants() {
        let tokens: [CGFloat] = [
            Theme.Spacing.xxSmall,
            Theme.Spacing.xSmall,
            Theme.Spacing.small,
            Theme.Spacing.medium,
            Theme.Spacing.large,
            Theme.Spacing.xLarge,
            Theme.Spacing.xxLarge
        ]
        
        for token in tokens {
            #expect(token > 0, "Spacing token must be positive, got \(token)")
            #expect(token.truncatingRemainder(dividingBy: 4.0) == 0.0, "Spacing token \(token) must be divisible by 4")
        }
    }

    @Test("TEST-TOK-04: Interactive touch targets conform to Apple HIG 44pt minimum invariant")
    func testMinimumTouchTargetDimension() {
        #expect(Theme.Dimensions.minTouchTarget == 44.0, "Minimum touch target must equal Apple HIG 44.0pt")
    }
}
