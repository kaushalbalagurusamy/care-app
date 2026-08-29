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
        let fonts = ["Poppins-Bold.ttf", "Poppins-SemiBold.ttf", "Poppins-Medium.ttf", "Poppins-Regular.ttf"]
        for font in fonts {
            if let url = Bundle.main.url(forResource: font, withExtension: nil) {
                CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
            }
        }
    }
}
