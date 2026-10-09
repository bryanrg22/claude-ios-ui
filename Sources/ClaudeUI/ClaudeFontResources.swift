#if canImport(UIKit)
    import CoreText
    import Foundation

    @MainActor enum ClaudeFontResources {
        private static let registration: Void = {
            for name in ["Newsreader", "Newsreader-Italic"] {
                if let url = Bundle.module.url(forResource: name, withExtension: "ttf") {
                    CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
                }
            }
        }()
        static func register() { _ = registration }
    }
#endif
