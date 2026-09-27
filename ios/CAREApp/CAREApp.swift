import SwiftUI
import CoreText

@main
struct CAREApp: App {
    init() {
        registerCustomFonts()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
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
