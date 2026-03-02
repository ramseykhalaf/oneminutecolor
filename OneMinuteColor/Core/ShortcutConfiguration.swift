import Foundation

public struct ShortcutConfiguration: Sendable {
    public let shortcutName: String
    public let shortcutInstallURLString: String
    public let callbackURLScheme: String

    public init(shortcutName: String, shortcutInstallURLString: String, callbackURLScheme: String = "oneminutecolor") {
        self.shortcutName = shortcutName
        self.shortcutInstallURLString = shortcutInstallURLString
        self.callbackURLScheme = callbackURLScheme
    }

    public static var appDefault: ShortcutConfiguration {
        if usesBritishEnglish {
            return ShortcutConfiguration(
                shortcutName: "One Minute Colour",
                shortcutInstallURLString: "https://www.icloud.com/shortcuts/6915d50d548b45f2bf826ffaa2bd55ee"
            )
        } else {
            return ShortcutConfiguration(
                shortcutName: "One Minute Color",
                shortcutInstallURLString: "https://www.icloud.com/shortcuts/12ae0e04fac8481a8c64ae6f60b880ae"
            )
        }
    }

    private static var usesBritishEnglish: Bool {
        guard let region = Locale.current.language.region?.identifier else { return false }
        return ["GB", "AU", "NZ", "IE", "ZA", "IN"].contains(region)
    }
}
