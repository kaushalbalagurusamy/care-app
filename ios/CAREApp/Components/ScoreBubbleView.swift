import SwiftUI

// MARK: - Reusable Circular Score Bubble Gauge (Figma Frame 29:4)
public struct ScoreBubbleView: View {
    public let score: Int
    public let maxScore: Int
    public let title: String?
    
    public init(score: Int, maxScore: Int = 100, title: String? = nil) {
        self.score = score
        self.maxScore = maxScore
        self.title = title
    }
    
    public var scoreText: String {
        return "\(score)/\(maxScore)"
    }
    
    public var safetyTier: SafetyTier {
        let normalized = (Double(score) / Double(max(maxScore, 1))) * 100.0
        if normalized >= 75.0 {
            return .healthy
        } else if normalized >= 60.0 {
            return .moderate
        } else {
            return .highRisk
        }
    }
    
    public var body: some View {
        ZStack {
            // Outer subtle background circle
            Circle()
                .fill(safetyTier.backgroundColor)
                .frame(width: 140, height: 140)
            
            // Concentric border ring
            Circle()
                .stroke(safetyTier.tierColor.opacity(0.3), lineWidth: 8)
                .frame(width: 120, height: 120)
            
            // Center Content
            VStack(spacing: 2) {
                if let title = title {
                    Text(title)
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                
                Text(scoreText)
                    .font(Theme.Typography.scoreDisplay)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Text(safetyTier.rawValue)
                    .font(Theme.Typography.caption)
                    .foregroundColor(safetyTier.tierColor)
            }
        }
    }
}
