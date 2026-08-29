import SwiftUI

// MARK: - Reusable Page Indicator Dots (Figma Frame 29:4)
public struct PageIndicatorDots: View {
    public let totalCount: Int
    public let currentIndex: Int
    public var onSelectIndex: ((Int) -> Void)?
    
    public init(totalCount: Int, currentIndex: Int, onSelectIndex: ((Int) -> Void)? = nil) {
        self.totalCount = totalCount
        self.currentIndex = min(max(currentIndex, 0), max(totalCount - 1, 0))
        self.onSelectIndex = onSelectIndex
    }
    
    public var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalCount, id: \.self) { index in
                Button(action: {
                    onSelectIndex?(index)
                }) {
                    Circle()
                        .fill(index == currentIndex ? Theme.Colors.primary : Color(hex: "#CBD5E1"))
                        .frame(width: index == currentIndex ? 7.5 : 6.5, height: index == currentIndex ? 7.5 : 6.5)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentIndex)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(height: 10)
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
