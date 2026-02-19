import SwiftUI

struct ContentView: View {
    @Environment(\.openURL) private var openURL

    private let actionHandler = ButtonActionHandler(configuration: .appDefault)

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
        _ = actionHandler.startOneMinuteColorButtonTapped { url in
            openURL(url)
        }
    }

    private func installShortcut() {
        _ = actionHandler.installShortcutButtonTapped { url in
            openURL(url)
        }
    }
}
