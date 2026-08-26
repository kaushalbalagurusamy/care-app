import SwiftUI

// MARK: - Reusable Page Indicator Dots (Figma Frame 29:4)
public struct PageIndicatorDots: View {
    public let totalCount: Int
    public let currentIndex: Int
    
    public init(totalCount: Int, currentIndex: Int) {
        self.totalCount = totalCount
        self.currentIndex = min(max(currentIndex, 0), max(totalCount - 1, 0))
    }
    
    public var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<totalCount, id: \.self) { index in
                Circle()
                    .fill(index == currentIndex ? Theme.Colors.primary : Theme.Colors.dividerMedium)
                    .frame(width: 8, height: 8)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentIndex)
            }
        }
        .frame(height: 8)
    }
}

// MARK: - Previews
#Preview("Page Indicator Dots") {
    VStack(spacing: 12) {
        PageIndicatorDots(totalCount: 5, currentIndex: 0)
        PageIndicatorDots(totalCount: 5, currentIndex: 2)
        PageIndicatorDots(totalCount: 5, currentIndex: 4)
    }
    .padding(20)
}
