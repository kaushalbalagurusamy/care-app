import SwiftUI
import CoreText

@main
struct CAREApp: App {
    init() {
        registerCustomFonts()
    }
    
    var body: some Scene {
        WindowGroup {
            AppLaunchView()
        }
    }
    
    private func registerCustomFonts() {
        let fontNames = ["Poppins-Bold", "Poppins-SemiBold", "Poppins-Medium", "Poppins-Regular"]
        for fontName in fontNames {
            if let url = Bundle.main.url(forResource: fontName, withExtension: "ttf") ?? Bundle.main.url(forResource: fontName + ".ttf", withExtension: nil) {
                var error: Unmanaged<CFError>?
                CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error)
            }
        }
    }
}

@MainActor
private struct AppLaunchView: View {
    @State private var launch: Result<AppEnvironment, Error> = Result { try AppEnvironment.makeLive() }

    var body: some View {
        switch launch {
        case .success(let environment):
            ContentView(environment: environment)
        case .failure:
            VStack(spacing: 18) {
                Image(systemName: "externaldrive.badge.exclamationmark")
                    .font(.system(size: 42))
                Text("Your saved data could not be opened")
                    .font(.headline)
                Text("Your data has not been cleared. Check device storage and try again. If this continues, contact support before reinstalling the app.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                Button("Try Again") { launch = Result { try AppEnvironment.makeLive() } }
                    .buttonStyle(.borderedProminent)
            }
            .padding(30)
        }
    }
}
