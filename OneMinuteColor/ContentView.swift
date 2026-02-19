import SwiftUI

struct ContentView: View {
    @Environment(\.openURL) private var openURL

    // Replace this with your published iCloud shortcut share link.
    // The shortcut should:
    // 1) Set Color Filters: Off
    // 2) Wait: 60 seconds
    // 3) Set Color Filters: On (Grayscale)
    private let shortcutInstallURLString = "https://www.icloud.com/shortcuts/REPLACE_WITH_YOUR_LINK"
    private let shortcutName = "One Minute Color"

    var body: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 0)

            Text("One Minute Color")
                .font(.system(size: 38, weight: .heavy, design: .rounded))
                .multilineTextAlignment(.center)

            Button(action: runShortcut) {
                Text("Start 1 Minute Color")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .frame(maxWidth: .infinity, minHeight: 220)
            }
            .buttonStyle(.borderedProminent)

            Button(action: installShortcut) {
                Text("Install Shortcut")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .frame(maxWidth: .infinity, minHeight: 56)
            }
            .buttonStyle(.bordered)

            Text("Add this shortcut to Control Center from the Shortcuts app after installing it.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer(minLength: 0)
        }
        .padding(24)
    }

    private func runShortcut() {
        guard let url = ShortcutLinkBuilder.runShortcutURL(shortcutName: shortcutName) else { return }
        openURL(url)
    }

    private func installShortcut() {
        guard let url = ShortcutLinkBuilder.installShortcutURL(from: shortcutInstallURLString) else { return }
        openURL(url)
    }
}
