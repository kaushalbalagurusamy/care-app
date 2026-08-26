import SwiftUI

// MARK: - Theme Typography Tokens
extension Theme {
    public enum Typography {
        /// Poppins font resolver with robust fallback
        public static func poppins(_ weight: PoppinsWeight, size: CGFloat) -> Font {
            Font.custom(weight.fontName, size: size)
        }
        
        public enum PoppinsWeight {
            case bold
            case semiBold
            case medium
            case regular
            
            var fontName: String {
                switch self {
                case .bold: return "Poppins-Bold"
                case .semiBold: return "Poppins-SemiBold"
                case .medium: return "Poppins-Medium"
                case .regular: return "Poppins-Regular"
                }
            }
        }
        
        /// 36pt SemiBold - App splash title & branding
        public static let logoTitle: Font = poppins(.bold, size: 36)
        
        /// 28pt Bold - Big score displays & major metrics
        public static let scoreDisplay: Font = poppins(.bold, size: 28)
        
        /// 24pt Bold - Welcome titles & Main screen headings (Figma Frame 5:19)
        public static let welcomeTitle: Font = poppins(.bold, size: 24)
        
        /// 20pt Bold - Section titles & modal headers
        public static let title2: Font = poppins(.bold, size: 20)
        
        /// 18pt SemiBold - Sub-headings & question prompts
        public static let headline: Font = poppins(.semiBold, size: 18)
        
        /// 16pt SemiBold / Bold - Card titles & primary button labels (Figma 5:28)
        public static let cardTitle: Font = poppins(.bold, size: 16)
        
        /// 15pt Medium / Regular - Standard body copy & options text
        public static let body: Font = poppins(.regular, size: 15)
        
        /// 13pt SemiBold - Home pill label & Streak text (Figma 5:14, 5:49)
        public static let menuLabel: Font = poppins(.semiBold, size: 13)
        
        /// 12pt Bold - Card index markers (Figma 5:24)
        public static let cardIndex: Font = poppins(.bold, size: 12)
        
        /// 10pt Medium - Card subtitles (Figma 5:29)
        public static let cardSubtitle: Font = poppins(.medium, size: 10)
        
        /// 14pt Medium - Secondary descriptions
        public static let subheadline: Font = poppins(.medium, size: 14)
        
        /// 13pt Regular - Secondary metadata & timestamp annotations
        public static let callout: Font = poppins(.regular, size: 13)
        
        /// 11pt-12pt SemiBold / Medium - Small status badges & slider tick labels
        public static let caption: Font = poppins(.medium, size: 12)
        
        /// 9pt-10pt SemiBold - Mini category dots & compact pill badges
        public static let miniBadge: Font = poppins(.semiBold, size: 10)
        
        // Convenience aliases
        public static let title: Font = welcomeTitle
        public static let title1: Font = welcomeTitle
        public static let questionText: Font = headline
    }
}
