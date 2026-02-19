import AppIntents
import SwiftUI

@main
struct OneMinuteColorApp: App {
    init() {
        OneMinuteColorAppShortcuts.updateAppShortcutParameters()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
