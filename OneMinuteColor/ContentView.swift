import SwiftUI

private struct CarouselStep: Identifiable {
    let id: Int
    let image: String
    let caption: String
}

private let carouselSteps: [CarouselStep] = [
    CarouselStep(id: 0, image: "Step-LongPress", caption: "Long press Control Centre"),
    CarouselStep(id: 1, image: "Step-AddControl", caption: "Tap + Add a Control"),
    CarouselStep(id: 2, image: "Step-SearchShortcuts", caption: "Search for Shortcuts"),
    CarouselStep(id: 3, image: "Step-FindShortcut", caption: "Find One Minute Colour"),
]

struct ContentView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("primaryButtonMode") private var storedPrimaryButtonMode = "install"

    private let actionHandler = ButtonActionHandler(configuration: .appDefault)
    @State private var pendingInstallReturn = false
    @State private var statusMessage = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Text("One Minute Color")
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                    .multilineTextAlignment(.center)
                    .padding(.top, 48)

                // Step 1 – Install
                stepSection(number: 1, title: "Install") {
                    Button(action: openInstallShortcut) {
                        Text("Install One Minute Color")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .frame(maxWidth: .infinity, minHeight: 56)
                    }
                    .buttonStyle(.borderedProminent)
                }

                // Step 2 – Add to Control Centre
                stepSection(number: 2, title: "Add to Control Centre") {
                    TabView {
                        ForEach(carouselSteps) { step in
                            VStack(spacing: 12) {
                                Image(step.image)
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 16))

                                Text(step.caption)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 32)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .frame(height: 340)
                }

                Divider()
                    .padding(.horizontal, 24)

                // Run button (fallback)
                Button(action: runShortcut) {
                    Label("Run One Minute Color", systemImage: "play.fill")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .frame(maxWidth: .infinity, minHeight: 48)
                }
                .buttonStyle(.bordered)

                if !statusMessage.isEmpty {
                    Text(statusMessage)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                Spacer(minLength: 32)
            }
            .padding(.horizontal, 24)
        }
        .onOpenURL(perform: handleIncomingURL)
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active, pendingInstallReturn else { return }
            pendingInstallReturn = false
            storedPrimaryButtonMode = "run"
            statusMessage = "Installed! You can now add it to Control Centre."
        }
    }

    // MARK: - Helpers

    private func stepSection<Content: View>(
        number: Int,
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(number). \(title)")
                .font(.title2.weight(.bold))
            content()
        }
    }

    // MARK: - Actions

    private func openInstallShortcut() {
        pendingInstallReturn = true
        _ = actionHandler.installShortcutButtonTapped { url in
            openURL(url)
        }
        statusMessage = "Install in Shortcuts, then return to this app."
    }

    private func runShortcut() {
        let url = actionHandler.startOneMinuteColorButtonTappedWithCallback { destination in
            openURL(destination)
        }

        if url == nil {
            storedPrimaryButtonMode = "install"
            statusMessage = "Could not start shortcut. Install One Minute Color first."
        } else {
            statusMessage = "Running One Minute Color…"
        }
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
            storedPrimaryButtonMode = "run"
            statusMessage = "Ready. Add it to Control Centre from Shortcuts."
        case "cancel":
            statusMessage = "Shortcut canceled."
        case "error":
            storedPrimaryButtonMode = "install"
            statusMessage = "Shortcut not available. Tap Install One Minute Color."
        default:
            break
        }
    }
}
