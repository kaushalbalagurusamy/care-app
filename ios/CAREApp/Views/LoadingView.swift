import SwiftUI

// MARK: - Screen 1: Loading & Brand Splash View (Figma Frame 3:2 — 1:1 Match)
public struct LoadingView: View {
    public let router: AppRouter?
    public let onFinished: (() -> Void)?
    
    public init(router: AppRouter? = nil, onFinished: (() -> Void)? = nil) {
        self.router = router
        self.onFinished = onFinished
    }
    
    public var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 28) {
                Spacer()
                
                // Pristine Direct Figma Logo Illustration (256x288)
                Image("care_logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 240, height: 260)
                
                // Exact Typography: Poppins SemiBold 36pt, Tracking 5.0, Color #12A3D4 (No subtext)
                Text("C.A.R.E.")
                    .font(.custom("Poppins-SemiBold", size: 36))
                    .tracking(6.0)
                    .foregroundColor(Color(red: 18/255.0, green: 163/255.0, blue: 212/255.0))
                
                Spacer()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeOut(duration: 0.35)) {
                    if let onFinished = onFinished {
                        onFinished()
                    } else {
                        router?.navigate(to: .home)
                    }
                }
            }
        }
        .onTapGesture {
            withAnimation(.easeOut(duration: 0.2)) {
                if let onFinished = onFinished {
                    onFinished()
                } else {
                    router?.navigate(to: .home)
                }
            }
        }
    }
}

// MARK: - Previews
#Preview("Loading View") {
    LoadingView()
}
