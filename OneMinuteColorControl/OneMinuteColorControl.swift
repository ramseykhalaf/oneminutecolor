import AppIntents
import SwiftUI
import WidgetKit

struct StartOneMinuteColorControl: ControlWidget {
    static let kind = "com.ramseykhalaf.oneminutecolor.start-one-minute-color"

    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: Self.kind) {
            ControlWidgetButton(
                action: StartOneMinuteColorControlIntent(),
                label: {
                    Text("One Minute Color")
                },
                actionLabel: { _ in
                    Image("OneMinuteColorControlIcon")
                        .resizable()
                        .scaledToFit()
                }
            )
        }
        .displayName("One Minute Color")
        .description("Run One Minute Color from Control Center.")
    }
}

struct StartOneMinuteColorControlIntent: AppIntent {
    static let title: LocalizedStringResource = "One Minute Color"
    static let description = IntentDescription("Runs the One Minute Color shortcut.")

    func perform() async throws -> some IntentResult & OpensIntent {
        guard let url = shortcutRunURL(shortcutName: "One Minute Color") else {
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
