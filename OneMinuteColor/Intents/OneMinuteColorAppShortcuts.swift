import AppIntents

struct OneMinuteColorAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: StartOneMinuteColorIntent(),
            phrases: [
                "Start one minute color in \(.applicationName)",
                "Run one minute color in \(.applicationName)"
            ],
            shortTitle: "1 Minute Color",
            systemImageName: "timer"
        )
    }

    static var shortcutTileColor: ShortcutTileColor = .orange
}
