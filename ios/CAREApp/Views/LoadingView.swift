import SwiftUI

// MARK: - Screen 1: Loading & Brand Splash View (Figma Frame 3:2)
public struct LoadingView: View {
    public let router: AppRouter?
    public let onFinished: (() -> Void)?
    
    @State private var isAnimating: Bool = false
    
    public init(router: AppRouter? = nil, onFinished: (() -> Void)? = nil) {
        self.router = router
        self.onFinished = onFinished
    }
    
    public var body: some View {
        ZStack {
            Theme.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                // Brand Logo Graphic
                Image("care_logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 140, height: 140)
                    .scaleEffect(isAnimating ? 1.0 : 0.85)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .animation(.spring(response: 0.8, dampingFraction: 0.7), value: isAnimating)
                
                VStack(spacing: 8) {
                    Text("C.A.R.E.")
                        .font(Theme.Typography.title)
                        .foregroundColor(Theme.Colors.textPrimary)
                    
                    Text("Connectedness & Relational Evaluation")
                        .font(Theme.Typography.subheadline)
                        .foregroundColor(Theme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .opacity(isAnimating ? 1.0 : 0.0)
                .animation(.easeIn(duration: 0.6).delay(0.2), value: isAnimating)
                
                Spacer()
            }
            .padding(.horizontal, 32)
        }
        .onAppear {
            isAnimating = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                if let onFinished = onFinished {
                    onFinished()
                } else {
                    router?.navigate(to: .home)
                }
            }
        }
        .onTapGesture {
            if let onFinished = onFinished {
                onFinished()
            } else {
                router?.navigate(to: .home)
            }
        }
    }
}

// MARK: - Previews
#Preview("Loading View") {
    LoadingView()
}
