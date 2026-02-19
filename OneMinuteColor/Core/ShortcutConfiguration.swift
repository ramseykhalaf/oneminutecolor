import Foundation

public struct ShortcutConfiguration: Sendable {
    public let shortcutName: String
    public let shortcutInstallURLString: String

    public init(shortcutName: String, shortcutInstallURLString: String) {
        self.shortcutName = shortcutName
        self.shortcutInstallURLString = shortcutInstallURLString
    }

    public static let appDefault = ShortcutConfiguration(
        shortcutName: "One Minute Color",
        shortcutInstallURLString: "https://www.icloud.com/shortcuts/12ae0e04fac8481a8c64ae6f60b880ae"
    )
}
