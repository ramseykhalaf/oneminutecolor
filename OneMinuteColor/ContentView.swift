import SwiftUI

private enum PrimaryButtonMode: String {
    case install
    case run

    var title: String {
        switch self {
        case .install:
            return "Install One Minute Color"
        case .run:
            return "One Minute Color"
        }
    }
}

struct ContentView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("primaryButtonMode") private var storedPrimaryButtonMode = PrimaryButtonMode.install.rawValue

    private let actionHandler = ButtonActionHandler(configuration: .appDefault)
    @State private var pendingInstallReturn = false
    @State private var statusMessage = "Install once, then tap One Minute Color to start."

    private var primaryButtonMode: PrimaryButtonMode {
        get { PrimaryButtonMode(rawValue: storedPrimaryButtonMode) ?? .install }
        nonmutating set { storedPrimaryButtonMode = newValue.rawValue }
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 0)

            Text("One Minute Color")
                .font(.system(size: 38, weight: .heavy, design: .rounded))
                .multilineTextAlignment(.center)

            Button(action: primaryButtonTapped) {
                Text(primaryButtonMode.title)
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .frame(maxWidth: .infinity, minHeight: 220)
            }
            .buttonStyle(.borderedProminent)

            Text(statusMessage)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer(minLength: 0)
        }
        .padding(24)
        .onOpenURL(perform: handleIncomingURL)
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active, pendingInstallReturn else { return }
            pendingInstallReturn = false
            primaryButtonMode = .run
            statusMessage = "Installed? Tap One Minute Color."
        }
    }

    private func primaryButtonTapped() {
        switch primaryButtonMode {
        case .install:
            openInstallShortcut()
        case .run:
            let url = actionHandler.startOneMinuteColorButtonTappedWithCallback { destination in
                openURL(destination)
            }

            if url == nil {
                primaryButtonMode = .install
                statusMessage = "Could not start shortcut. Install One Minute Color first."
            } else {
                statusMessage = "Running One Minute Color..."
            }
        }
    }

    private func openInstallShortcut() {
        pendingInstallReturn = true
        _ = actionHandler.installShortcutButtonTapped { url in
            openURL(url)
        }
        statusMessage = "Install in Shortcuts, then return to this app."
    }

    private func handleIncomingURL(_ url: URL) {
        let expectedScheme = ShortcutConfiguration.appDefault.callbackURLScheme.lowercased()
        guard url.scheme?.lowercased() == expectedScheme,
              url.host?.lowercased() == "shortcut" else {
            return
        }

        let event = url.pathComponents.dropFirst().first?.lowercased()
        switch event {
        case "success":
            primaryButtonMode = .run
            statusMessage = "Ready. Add it to Control Center from Shortcuts."
        case "cancel":
            statusMessage = "Shortcut canceled."
        case "error":
            primaryButtonMode = .install
            statusMessage = "Shortcut not available. Tap Install One Minute Color."
        default:
            break
        }
    }
}
