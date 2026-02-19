import Foundation

public struct ButtonActionHandler {
    private let configuration: ShortcutConfiguration

    public init(configuration: ShortcutConfiguration) {
        self.configuration = configuration
    }

    @discardableResult
    public func startOneMinuteColorButtonTapped(openURL: (URL) -> Void) -> URL? {
        guard let url = ShortcutLinkBuilder.runShortcutURL(shortcutName: configuration.shortcutName) else {
            return nil
        }

        openURL(url)
        return url
    }

    @discardableResult
    public func startOneMinuteColorButtonTappedWithCallback(openURL: (URL) -> Void) -> URL? {
        guard let url = ShortcutLinkBuilder.runShortcutCallbackURL(
            shortcutName: configuration.shortcutName,
            callbackURLScheme: configuration.callbackURLScheme
        ) else {
            return nil
        }

        openURL(url)
        return url
    }

    @discardableResult
    public func installShortcutButtonTapped(openURL: (URL) -> Void) -> URL? {
        guard let url = ShortcutLinkBuilder.installShortcutURL(from: configuration.shortcutInstallURLString) else {
            return nil
        }

        openURL(url)
        return url
    }
}
