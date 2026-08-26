import SwiftUI

// MARK: - Theme Typography Tokens
extension Theme {
    public enum Typography {
        /// 36pt SemiBold - App splash title & branding
        public static let logoTitle: Font = .system(size: 36, weight: .semibold, design: .rounded)
        
        /// 28pt Bold - Big score displays & major metrics
        public static let scoreDisplay: Font = .system(size: 28, weight: .bold, design: .rounded)
        
        /// 24pt Bold / SemiBold - Main screen headings & welcome titles
        public static let title1: Font = .system(size: 24, weight: .bold, design: .default)
        
        /// 20pt Bold - Section titles & modal headers
        public static let title2: Font = .system(size: 20, weight: .bold, design: .default)
        
        /// 18pt SemiBold - Sub-headings & question prompts
        public static let headline: Font = .system(size: 18, weight: .semibold, design: .default)
        
        /// 16pt SemiBold - Card titles & primary button labels
        public static let cardTitle: Font = .system(size: 16, weight: .semibold, design: .default)
        
        /// 15pt Medium / Regular - Standard body copy & options text
        public static let body: Font = .system(size: 15, weight: .regular, design: .default)
        
        /// 14pt Medium - Secondary descriptions & input field labels
        public static let subheadline: Font = .system(size: 14, weight: .medium, design: .default)
        
        /// 13pt Regular - Secondary metadata & timestamp annotations
        public static let callout: Font = .system(size: 13, weight: .regular, design: .default)
        
        /// 11pt-12pt SemiBold / Medium - Small status badges & slider tick labels
        public static let caption: Font = .system(size: 12, weight: .medium, design: .default)
        
        /// 9pt-10pt SemiBold - Mini category dots & compact pill badges
        public static let miniBadge: Font = .system(size: 10, weight: .semibold, design: .default)
    }
}
