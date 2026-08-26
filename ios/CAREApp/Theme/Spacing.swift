import SwiftUI

// MARK: - Theme Spacing & Radii Tokens
extension Theme {
    public enum Spacing {
        /// 4pt - Micro spacing (icon-to-text, indicator padding)
        public static let xxSmall: CGFloat = 4
        
        /// 8pt - Tight spacing (tag padding, chip gaps)
        public static let xSmall: CGFloat = 8
        
        /// 12pt - Standard compact spacing (card internal elements)
        public static let small: CGFloat = 12
        
        /// 16pt - Default view padding & vertical component spacing
        public static let medium: CGFloat = 16
        
        /// 24pt - Section gaps & card vertical padding
        public static let large: CGFloat = 24
        
        /// 32pt - Major section breaks & hero spacing
        public static let xLarge: CGFloat = 32
        
        /// 48pt - Screen boundary spacing & bottom action margins
        public static let xxLarge: CGFloat = 48
    }
    
    public enum Radius {
        /// 4pt - Small borders & micro tags
        public static let small: CGFloat = 4
        
        /// 8pt - Status badges & input fields
        public static let badge: CGFloat = 8
        
        /// 12pt - Action buttons & option cards
        public static let button: CGFloat = 12
        
        /// 16pt - Primary dashboard cards & modals
        public static let card: CGFloat = 16
        
        /// 24pt - Interactive selection pills & pill buttons
        public static let pill: CGFloat = 24
        
        /// 100pt - Fully circular badges & score gauges
        public static let full: CGFloat = 100
    }
    
    public enum Dimensions {
        /// 44pt - Apple Human Interface Guidelines minimum touch target height/width
        public static let minTouchTarget: CGFloat = 44
        
        /// 52pt - Standard primary action button height
        public static let primaryButtonHeight: CGFloat = 52
        
        /// 40pt - Navigation icon button size
        public static let navButtonSize: CGFloat = 40
    }
}
