import SwiftUI

// MARK: - Scroll Bottom Sentinel Preference Key
public struct ScrollBottomSentinelKey: PreferenceKey {
    public static var defaultValue: CGFloat? = nil
    
    public static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
        if let next = nextValue() {
            value = next
        }
    }
}

// MARK: - Scroll Bottom Sentinel View
/// A zero-overhead, 1pt sentinel view placed at the very bottom of scrollable content.
/// It measures its coordinate relative to a designated scroll space and notifies when it enters the viewport.
public struct ScrollBottomSentinel: View {
    public let spaceName: String
    public let onReachedBottom: (() -> Void)?
    
    public init(
        spaceName: String = "ScrollBottomSpace",
        onReachedBottom: (() -> Void)? = nil
    ) {
        self.spaceName = spaceName
        self.onReachedBottom = onReachedBottom
    }
    
    public var body: some View {
        GeometryReader { proxy in
            Color.clear
                .preference(
                    key: ScrollBottomSentinelKey.self,
                    value: proxy.frame(in: .named(spaceName)).maxY
                )
        }
        .frame(height: 1)
        .onAppear {
            onReachedBottom?()
        }
    }
}

// MARK: - Scroll Bottom Tracking Modifier
/// Tracks the scroll position of a ScrollView container and unlocks a binding when the user reaches the bottom.
public struct TrackScrollBottomModifier: ViewModifier {
    @Binding public var isUnlocked: Bool
    public let spaceName: String
    @State private var viewportHeight: CGFloat = 0
    @State private var lastSentinelY: CGFloat? = nil
    
    public init(
        isUnlocked: Binding<Bool>,
        spaceName: String = "ScrollBottomSpace"
    ) {
        self._isUnlocked = isUnlocked
        self.spaceName = spaceName
    }
    
    public func body(content: Content) -> some View {
        content
            .coordinateSpace(name: spaceName)
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            viewportHeight = geo.size.height
                            evaluateUnlock()
                        }
                        .onChange(of: geo.size.height) { _, newH in
                            viewportHeight = newH
                            evaluateUnlock()
                        }
                }
            )
            .onPreferenceChange(ScrollBottomSentinelKey.self) { sentinelY in
                lastSentinelY = sentinelY
                evaluateUnlock()
            }
    }
    
    private func evaluateUnlock() {
        guard !isUnlocked, let y = lastSentinelY, viewportHeight > 0 else { return }
        // If the bottom sentinel has reached or entered within the visible viewport bounds
        // (with a 20pt buffer for elastic pull / overscroll physics)
        if y <= viewportHeight + 20 {
            withAnimation(.easeInOut(duration: 0.3)) {
                isUnlocked = true
            }
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
    }
}

extension View {
    /// Tracks when the user has scrolled all the way to the bottom of this ScrollView.
    public func trackScrollBottom(
        isUnlocked: Binding<Bool>,
        spaceName: String = "ScrollBottomSpace"
    ) -> some View {
        self.modifier(TrackScrollBottomModifier(isUnlocked: isUnlocked, spaceName: spaceName))
    }
}
