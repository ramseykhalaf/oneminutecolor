import AppIntents
import UIKit

struct StartOneMinuteColorIntent: AppIntent {
    static let title: LocalizedStringResource = "Start 1 Minute Color"
    static let description = IntentDescription("Runs the One Minute Color shortcut.")
    static let openAppWhenRun = true

    @MainActor
    func perform() async throws -> some IntentResult {
        guard let url = ShortcutLinkBuilder.runShortcutURL(
            shortcutName: ShortcutConfiguration.appDefault.shortcutName
        ) else {
            throw NSError(domain: "OneMinuteColor", code: 1)
        }

        _ = await UIApplication.shared.open(url)
        return .result()
    }
}
