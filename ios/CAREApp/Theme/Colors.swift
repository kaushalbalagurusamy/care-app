import SwiftUI

// MARK: - Color Extension for Hex Initializers
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Theme Colors
public enum Theme {
    public enum Colors {
        // Brand & Interactive Accents
        public static let primary = Color(hex: "#246BB8")
        public static let brandCyan = Color(hex: "#12A3D4")
        public static let darkNavy = Color(hex: "#0F1D40")
        
        // Backgrounds & Surfaces
        public static let background = Color(hex: "#FFFFFF")
        public static let surfaceSecondary = Color(hex: "#F4F7F9")
        public static let cardSurface = Color(hex: "#EFF5FC")
        public static let cardSurfaceSelected = Color(hex: "#EBF2FA")
        public static let buttonSurfaceMuted = Color(hex: "#F0F5FD")
        
        // Dividers & Borders
        public static let dividerSubtle = Color(hex: "#E2E8F0")
        public static let dividerMedium = Color(hex: "#CCD6E0")
        public static let dividerActive = Color(hex: "#94A3B8")
        
        // Typography Colors
        public static let textPrimary = Color(hex: "#1E293B")
        public static let textSecondary = Color(hex: "#64748B")
        public static let textMuted = Color(hex: "#94A3B8")
        public static let textOnAccent = Color.white
        
        // Safety Status & Risk Palette (Matching Figma Soft Pastel Tones & Donut Opacities)
        public enum Safety {
            public static let lowRisk = Color(hex: "#6CBB9E")             // Safe (Soft Green)
            public static let lowRiskBackground = Color(hex: "#EBF7F2")
            
            public static let moderateRisk = Color(hex: "#ECDF96")        // Medium Risk (Soft Yellow)
            public static let moderateRiskBackground = Color(hex: "#FAF7E8")
            
            public static let highRisk = Color(hex: "#F3B0BD")            // High Risk (Soft Pink/Coral)
            public static let highRiskBackground = Color(hex: "#FDEEF1")
            
            public static let neutral = Color(hex: "#64748B")
        }
        
        // C.A.R.E. Assessment Domain Categories
        public enum Domains {
            public static let calm = Color(hex: "#ECDF96")        // C - Calm
            public static let accepted = Color(hex: "#F3B0BD")    // A - Accepted
            public static let resonant = Color(hex: "#ABDCFB")    // R - Resonant
            public static let energetic = Color(hex: "#6CBB9E")   // E - Energetic
        }
    }
}
