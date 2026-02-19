import Foundation

public enum ShortcutLinkBuilder {
    public static func runShortcutURL(shortcutName: String) -> URL? {
        let trimmed = shortcutName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        var components = URLComponents()
        components.scheme = "shortcuts"
        components.host = "run-shortcut"
        components.queryItems = [URLQueryItem(name: "name", value: trimmed)]
        return components.url
    }

    public static func runShortcutCallbackURL(shortcutName: String, callbackURLScheme: String) -> URL? {
        let trimmedName = shortcutName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return nil }

        let trimmedScheme = callbackURLScheme.trimmingCharacters(in: .whitespacesAndNewlines)
        guard isValidURLScheme(trimmedScheme) else { return nil }

        guard let successCallback = callbackURLString(scheme: trimmedScheme, event: "success"),
              let cancelCallback = callbackURLString(scheme: trimmedScheme, event: "cancel"),
              let errorCallback = callbackURLString(scheme: trimmedScheme, event: "error") else {
            return nil
        }

        var components = URLComponents()
        components.scheme = "shortcuts"
        components.host = "x-callback-url"
        components.path = "/run-shortcut"
        components.queryItems = [
            URLQueryItem(name: "name", value: trimmedName),
            URLQueryItem(name: "x-success", value: successCallback),
            URLQueryItem(name: "x-cancel", value: cancelCallback),
            URLQueryItem(name: "x-error", value: errorCallback)
        ]
        return components.url
    }

    public static func installShortcutURL(from rawValue: String) -> URL? {
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: trimmed),
              let scheme = url.scheme?.lowercased(),
              ["http", "https"].contains(scheme),
              url.host != nil else {
            return nil
        }

        return url
    }

    private static func callbackURLString(scheme: String, event: String) -> String? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = "shortcut"
        components.path = "/\(event)"
        return components.url?.absoluteString
    }

    private static func isValidURLScheme(_ scheme: String) -> Bool {
        scheme.range(of: "^[A-Za-z][A-Za-z0-9+.-]*$", options: .regularExpression) != nil
    }
}
