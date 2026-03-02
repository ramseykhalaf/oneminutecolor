import AppIntents
import SwiftUI
import WidgetKit

private var localShortcutName: String {
    guard let region = Locale.current.language.region?.identifier else { return "One Minute Color" }
    let british = ["GB", "AU", "NZ", "IE", "ZA", "IN"].contains(region)
    return british ? "One Minute Colour" : "One Minute Color"
}

struct StartOneMinuteColorControl: ControlWidget {
    static let kind = "com.ramseykhalaf.oneminutecolor.start-one-minute-color"

    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: Self.kind) {
            ControlWidgetButton(
                action: StartOneMinuteColorControlIntent(),
                label: {
                    Text(localShortcutName)
                },
                actionLabel: { _ in
                    Image("OneMinuteColorControlIcon")
                        .resizable()
                        .scaledToFit()
                }
            )
        }
        .displayName(LocalizedStringResource(stringLiteral: localShortcutName))
        .description("Run \(localShortcutName) from Control Center.")
    }
}

struct StartOneMinuteColorControlIntent: AppIntent {
    static let title: LocalizedStringResource = "One Minute Color"
    static let description = IntentDescription("Runs the One Minute Color shortcut.")

    func perform() async throws -> some IntentResult & OpensIntent {
        guard let url = shortcutRunURL(shortcutName: localShortcutName) else {
            throw NSError(domain: "OneMinuteColorControl", code: 1)
        }

        return .result(opensIntent: OpenURLIntent(url))
    }

    private func shortcutRunURL(shortcutName: String) -> URL? {
        let trimmed = shortcutName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        var components = URLComponents()
        components.scheme = "shortcuts"
        components.host = "run-shortcut"
        components.queryItems = [URLQueryItem(name: "name", value: trimmed)]
        return components.url
    }
}
